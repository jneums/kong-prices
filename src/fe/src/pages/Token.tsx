import { useNavigate, useParams } from 'react-router';
import TokenPriceChart from '../components/TokenPriceChart';
import {
  Box,
  Button,
  Card,
  Chip,
  Container,
  Stack,
  Typography,
  useTheme,
} from '@mui/joy';
import { useGetHistoricalPrices, useGetMostRecentPrices } from '../api/prices';
import { PriceInfo } from '../declarations/be/be.did';
import TokenLogo from '../components/TokenLogo';
import { useState } from 'react';
import PeriodSelect from '../components/PeriodSelect';

export default function Token() {
  const { token } = useParams();
  const navigate = useNavigate();
  const [range, setRange] = useState('month');
  const theme = useTheme();

  if (!token) {
    return null;
  }

  const getMostRecentPrices = useGetMostRecentPrices();
  const getHistoricalPrices = useGetHistoricalPrices(token, range);

  const priceChange =
    getHistoricalPrices.data?.length && getHistoricalPrices.data.length > 1
      ? getHistoricalPrices.data[getHistoricalPrices.data.length - 1].price -
        getHistoricalPrices.data[0].price
      : 0;

  const priceChangePercentage =
    getHistoricalPrices.data?.length && getHistoricalPrices.data.length > 1
      ? ((getHistoricalPrices.data[getHistoricalPrices.data.length - 1].price -
          getHistoricalPrices.data[0].price) /
          getHistoricalPrices.data[0].price) *
        100
      : 0;

  const mappedPrices = getMostRecentPrices.data?.reduce(
    (acc: Record<string, PriceInfo>, priceInfo) => {
      acc[priceInfo.token] = priceInfo;
      return acc;
    },
    {},
  );

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Stack gap={2}>
        <Box>
          <Button
            size="sm"
            color="neutral"
            variant="plain"
            onClick={() => navigate(-1)}
            sx={{ ml: -1.5, color: theme.palette.text.tertiary }}>
            {'<- Back'}
          </Button>
        </Box>
        <Stack direction="row" gap={1.5}>
          <TokenLogo size="lg" symbol={token || ''} />
          <Stack gap={0.25}>
            <Typography level="title-lg">{token}</Typography>
            <Stack direction="row" gap={0.5} alignItems="baseline">
              <Typography level="body-sm">
                $
                {mappedPrices && token && token in mappedPrices
                  ? mappedPrices[token].currentPrice?.toLocaleString(
                      undefined,
                      {
                        minimumFractionDigits: 2,
                        maximumFractionDigits: 6,
                      },
                    )
                  : 0}{' '}
              </Typography>
              <Chip
                size="sm"
                color={priceChangePercentage >= 0 ? 'success' : 'danger'}
                component="span"
                sx={{
                  color:
                    priceChangePercentage >= 0
                      ? theme.palette.success[400]
                      : theme.palette.danger[400],
                  borderRadius: 'md',
                }}>
                {priceChangePercentage >= 0 ? '+' : ''}$
                {priceChange.toLocaleString(undefined, {
                  minimumFractionDigits: 2,
                  maximumFractionDigits: 6,
                })}{' '}
                ({priceChangePercentage.toFixed(2)}%)
              </Chip>
            </Stack>
          </Stack>
        </Stack>
        <Card sx={{ bgcolor: 'transparent' }}>
          <TokenPriceChart token={token!} range={range} />
        </Card>
        <PeriodSelect
          selectedPeriod={range}
          onPeriodChange={(period) => setRange(period)}
          chipColor={'neutral'}
        />
      </Stack>
    </Container>
  );
}
