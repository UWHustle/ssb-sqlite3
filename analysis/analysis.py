from collections import defaultdict
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

sns.set()

figsize = (8, 4)


def times():
    df = pd.read_csv('data/times.csv', index_col='query')
    df.loc['GM'] = np.exp(np.log(df).mean())

    df[['time_vanilla']].plot(kind='bar', figsize=figsize, legend=False)
    plt.xlabel('query')
    plt.ylabel('time (s)')
    plt.tight_layout()
    plt.savefig('latency.pdf')

    df.plot(kind='bar', figsize=figsize)
    plt.xlabel('query')
    plt.ylabel('time (s)')
    plt.legend(['vanilla', 'with bloom filter'])
    plt.tight_layout()
    plt.savefig('latency_bf.pdf')


def profiles():
    data = {}
    for name in ['1.1', '1.2', '1.3', '2.1', '2.2', '2.3', '3.1', '3.2', '3.3', '3.4', '4.1', '4.2', '4.3']:
        profile = defaultdict(int)
        with open(f'data/profiles/q{name}.txt', 'r') as f:
            for line in f:
                tokens = line.split()
                profile[tokens[4]] += int(tokens[1])

        data[name] = dict(profile)

    df = pd.DataFrame.from_dict(data, orient='index')
    df0 = df.loc[:, (df.max(axis=0) < 5e8)]
    df1 = df.loc[:, (df.max(axis=0) >= 5e8)]
    df1 = df1.assign(other=df0.sum(axis=1))

    df1.plot(kind='bar', stacked=True, figsize=figsize)
    plt.xlabel('query')
    plt.ylabel('TSC ticks')
    plt.tight_layout()
    plt.savefig('profile.pdf')


def sum_times():
    df = pd.read_csv('data/sum_times.csv', index_col='organization')

    df.plot(kind='bar', figsize=(2.7, figsize[1]), legend=False)
    plt.xlabel('organization')
    plt.ylabel('time (s)')
    plt.tight_layout()
    plt.savefig('sum_latency.pdf')


def sum_profiles():
    data = {}
    for name in ['standard', 'reordered', 'decomposed']:
        profile = defaultdict(int)
        with open(f'data/profiles/q{name}.txt', 'r') as f:
            for line in f:
                tokens = line.split()
                profile[tokens[4]] += int(tokens[1])

        data[name] = dict(profile)

    df = pd.DataFrame.from_dict(data, orient='index')
    df1 = df.loc[:, (df.max(axis=0) >= 1e8)]

    df1.plot(kind='bar', stacked=True, figsize=(2.7, figsize[1]))
    plt.xlabel('organization')
    plt.ylabel('TSC ticks')
    plt.tight_layout()
    plt.savefig('sum_profile.pdf')


if __name__ == '__main__':
    # times()
    # profiles()
    sum_times()
    sum_profiles()
