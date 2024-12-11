import { useNavigate } from 'react-router';
import { useGetMostRecentPrices, useGetTokens } from '../api/prices';
import { Container, List, ListItemButton, Stack, Typography } from '@mui/joy';
import { fromNullable } from '@dfinity/utils';
import { PriceInfo } from '../declarations/be/be.did';
import TokenLogo from '../components/TokenLogo';

export default function Home() {
  const navigate = useNavigate();
  const getTokens = useGetTokens();
  const getMostRecentPrices = useGetMostRecentPrices();

  const mappedPrices = getMostRecentPrices.data?.reduce(
    (acc: Record<string, PriceInfo>, priceInfo) => {
      acc[priceInfo.token] = priceInfo;
      return acc;
    },
    {},
  );

  const handleClick = (token: string) => {
    navigate(`/tokens/${token}`);
  };

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Stack gap={3}>
        <Stack>
          <Typography level="h4">Kong Price Tracker</Typography>
          <Typography level="body-sm">
            Welcome to the Kong Price Tracker! Here you can see the most recent
            prices of various tokens.
          </Typography>
        </Stack>
        <Stack>
          <Typography level="title-sm">Tokens</Typography>

          <List sx={{ gap: 1 }} size="lg">
            {getTokens.isLoading && (
              <ListItemButton
                variant="outlined"
                sx={{ borderRadius: 'md', py: 1 }}>
                <Typography level="body-sm">Loading...</Typography>
              </ListItemButton>
            )}
            {getTokens.data?.map((token) => (
              <ListItemButton
                variant="outlined"
                sx={{ borderRadius: 'md', py: 1 }}
                key={token}
                onClick={() => handleClick(token)}>
                <TokenLogo size="sm" symbol={token} />
                <Stack width="100%">
                  <Typography level="title-sm">{token}</Typography>
                  <Typography level="body-xs">
                    $
                    {mappedPrices && token in mappedPrices
                      ? mappedPrices[token].currentPrice?.toLocaleString(
                          undefined,
                          {
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 6,
                          },
                        )
                      : 0}
                  </Typography>
                </Stack>
              </ListItemButton>
            ))}
          </List>
        </Stack>
      </Stack>
    </Container>
  );
}
