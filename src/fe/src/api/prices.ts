import { useQuery } from 'react-query';
import { be } from '../declarations/be';
import { PriceInfo, SwapTransaction } from '../declarations/be/be.did';
import { toNullable } from '@dfinity/utils';

export const getTokens = {
  key: () => ['getTokens'],
  fn: async () => {
    const response = await be.getTokens();
    return response;
  },
};

export const useGetTokens = () => {
  return useQuery<string[]>(getTokens.key(), getTokens.fn);
};

export const getHistoricalPrices = {
  key: (tokens: string[], range: string) => [
    'getHistoricalPrices',
    tokens,
    range,
  ],
  fn: async (tokens: string[], range: string) => {
    const now = BigInt(Date.now() * 1_000_000); // Convert to nanoseconds
    let startDate: bigint | null = null;
    let granularity: string = 'hour';
    const endDate = toNullable(now);

    switch (range) {
      case 'hour':
        startDate = now - BigInt(60 * 60 * 1_000_000_000); // 1 hour in nanoseconds
        granularity = 'minute';
        break;
      case 'day':
        startDate = now - BigInt(24 * 60 * 60 * 1_000_000_000); // 1 day in nanoseconds
        granularity = 'hour';
        break;
      case 'week':
        startDate = now - BigInt(7 * 24 * 60 * 60 * 1_000_000_000); // 1 week in nanoseconds
        granularity = 'hour';
        break;
      case 'month':
        startDate = now - BigInt(30 * 24 * 60 * 60 * 1_000_000_000); // 1 month in nanoseconds
        granularity = 'day';
        break;
      case 'year':
        startDate = now - BigInt(365 * 24 * 60 * 60 * 1_000_000_000); // 1 year in nanoseconds
        granularity = 'day';
        break;
      case 'all':
        startDate = null; // No start date for max range
        granularity = 'day';
        break;
      default:
        throw new Error(`Invalid range: ${range}`);
    }

    const response = await be.getHistoricalPrices(
      tokens,
      toNullable(startDate),
      endDate,
      toNullable(granularity),
    );
    return response;
  },
};

export const useGetHistoricalPrices = (
  tokens: string[],
  range: string = 'month',
) => {
  return useQuery<[string, SwapTransaction[]][]>(
    getHistoricalPrices.key(tokens, range),
    () => getHistoricalPrices.fn(tokens, range),
    { refetchInterval: 10000 },
  );
};

export const getMostRecentPrices = {
  key: () => ['getMostRecentPrices'],
  fn: async () => {
    const response = await be.getMostRecentPrices();
    return response;
  },
};

export const useGetMostRecentPrices = () => {
  return useQuery<Array<PriceInfo>>(
    getMostRecentPrices.key(),
    getMostRecentPrices.fn,
    {
      refetchInterval: 10000,
    },
  );
};
