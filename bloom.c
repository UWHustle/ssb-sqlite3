#include <assert.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>

#include <sqlite3ext.h>
SQLITE_EXTENSION_INIT1

struct bloom_t {
  unsigned int size;
  unsigned char *data;
};

struct bloom_pos_t {
  unsigned int blk;
  unsigned char bit;
};

uint32_t murmur3_32(const unsigned char *key, size_t len) {
  size_t step = sizeof(uint32_t) / sizeof(unsigned char);

  uint32_t h = 42;
  uint32_t k;

  for (size_t i = len / step; i; i--) {
    memcpy(&k, key, sizeof(uint32_t));
    key += sizeof(uint32_t);

    k *= 0xcc9e2d51;
    k = (k << 15) | (k >> 17);
    k *= 0x1b873593;

    h ^= k;
    h = (h << 13) | (h >> 19);
    h = h * 5 + 0xe6546b64;
  }

  k = 0;
  for (size_t i = len % step; i; i--) {
    k <<= 8;
    k |= key[i - 1];
  }

  k *= 0xcc9e2d51;
  k = (k << 15) | (k >> 17);
  k *= 0x1b873593;

  h ^= k;

  h ^= len;
  h ^= h >> 16;
  h *= 0x85ebca6b;
  h ^= h >> 13;
  h *= 0xc2b2ae35;
  h ^= h >> 16;
  return h;
}

void bloom_init(struct bloom_t *bloom, unsigned int size) {
  assert(size > 0);

  unsigned char *data = malloc(size);
  memset(data, 0, size);

  bloom->size = size;
  bloom->data = data;
}

void bloom_free(void *bloom) {
  free(((struct bloom_t *)bloom)->data);
  free(bloom);
}

struct bloom_pos_t bloom_pos(struct bloom_t *bloom, const unsigned char *key,
                             size_t len) {
  uint32_t hash = murmur3_32(key, len);
  unsigned int blk = hash % bloom->size;
  unsigned char bit = (hash / bloom->size) % CHAR_BIT;
  struct bloom_pos_t pos = {blk, bit};
  return pos;
}

void bloom_set(struct bloom_t *bloom, const unsigned char *key, size_t len) {
  struct bloom_pos_t pos = bloom_pos(bloom, key, len);
  bloom->data[pos.blk] |= 1u << pos.bit;
}

unsigned char bloom_test(struct bloom_t *bloom, const unsigned char *key,
                         size_t len) {
  struct bloom_pos_t pos = bloom_pos(bloom, key, len);
  return (bloom->data[pos.blk] >> pos.bit) & 1u;
}

static void bloom_step(sqlite3_context *context, int argc,
                       sqlite3_value **argv) {
  assert(argc == 2);

  if (sqlite3_value_type(argv[0]) == SQLITE_NULL) {
    return;
  }

  struct bloom_t *bloom;
  bloom = sqlite3_aggregate_context(context, sizeof(*bloom));

  if (!bloom->data) {
    int size = sqlite3_value_int(argv[1]);

    if (size <= 0) {
      sqlite3_result_error(context,
                           "bloom filter size must be a positive integer", -1);
      return;
    }

    bloom_init(bloom, size);
  }

  const unsigned char *key = sqlite3_value_text(argv[0]);
  bloom_set(bloom, key, strlen((char *)key));
}

static void bloom_finalize(sqlite3_context *context) {
  struct bloom_t *bloom;
  bloom = sqlite3_aggregate_context(context, sizeof(*bloom));
  void *out = malloc(sizeof(*bloom));
  memcpy(out, bloom, sizeof(*bloom));
  sqlite3_result_blob(context, out, sizeof(*bloom), 0);
}

static void bloom_contains(sqlite3_context *context, int argc,
                           sqlite3_value **argv) {
  assert(argc == 2);

  struct bloom_t *bloom = (struct bloom_t *)sqlite3_value_blob(argv[0]);
  const unsigned char *key = sqlite3_value_text(argv[1]);
  sqlite3_result_int(context, bloom_test(bloom, key, strlen((char *)key)));
}

#ifdef _WIN32
__declspec(dllexport);
#endif

__attribute__((unused)) int
sqlite3_bloom_init(sqlite3 *db, char **pzErrMsg,
                   const sqlite3_api_routines *pApi) {
  SQLITE_EXTENSION_INIT2(pApi);
  int rc;
  (void)pzErrMsg;

  rc = sqlite3_create_function(db, "bloom", 2, SQLITE_ANY, 0, 0, bloom_step,
                               bloom_finalize);

  if (rc != SQLITE_OK) {
    return rc;
  }

  rc = sqlite3_create_function(db, "bloom_contains", 2, SQLITE_ANY, 0,
                               bloom_contains, 0, 0);

  return rc;
}
