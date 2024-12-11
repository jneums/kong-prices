import React, { useCallback } from 'react';
import { Box, Chip, ColorPaletteProp, Stack, useTheme } from '@mui/joy';

interface PeriodSelectProps {
  selectedPeriod: string;
  onPeriodChange: (period: string) => void;
  chipColor: ColorPaletteProp;
}

const periods = ['hour', 'day', 'week', 'month', 'year', 'all'];

const PeriodSelect: React.FC<PeriodSelectProps> = React.memo(
  ({ selectedPeriod, onPeriodChange, chipColor }) => {
    const theme = useTheme();

    const handlePeriodChange = useCallback(
      (periodValue: string) => {
        onPeriodChange(periodValue);
      },
      [onPeriodChange],
    );

    return (
      <Stack
        direction="row"
        sx={{
          gap: 1,
        }}>
        {periods.map((period) => (
          <Chip
            key={period}
            sx={{
              borderRadius: 'md',
              color:
                selectedPeriod === period
                  ? theme.palette.text.primary
                  : theme.palette.text.tertiary,
            }}
            variant={selectedPeriod === period ? 'solid' : 'soft'}
            color={chipColor}
            onClick={() => handlePeriodChange(period)}>
            {period}
          </Chip>
        ))}
      </Stack>
    );
  },
);

export default PeriodSelect;
