import { CurrencyBitcoin } from '@mui/icons-material';
import { Avatar, AvatarProps } from '@mui/joy';

export default function TokenLogo({
  symbol,
  ...avatarProps
}: { symbol: string } & AvatarProps) {
  const extension =
    symbol.startsWith('ck') ||
    [
      'ICP',
      'BOB',
      'Bits',
      'CHAT',
      'DKP',
      'nanas',
      'EXE',
      'nICP',
      'CLOWN',
      'WUMBO',
      'DAMONIC',
      'YUGE',
      'MCS',
      'PARTY',
      'ND64',
      'SNEED',
      'WTN',
    ].includes(symbol)
      ? 'svg'
      : 'png';
  return (
    <Avatar
      src={`/tokens/${symbol}.${extension}`}
      variant="soft"
      {...avatarProps}>
      <CurrencyBitcoin />
    </Avatar>
  );
}
