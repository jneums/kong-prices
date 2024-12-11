import React from 'react';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Tooltip,
  TimeScale,
} from 'chart.js';
import 'chartjs-adapter-date-fns';
import { Box, useTheme } from '@mui/joy';
import { useGetHistoricalPrices } from '../api/prices';

// Register the necessary components for Chart.js
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Tooltip,
  TimeScale,
);

interface TokenPriceChartProps {
  token: string;
  range: string;
}

const TokenPriceChart: React.FC<TokenPriceChartProps> = React.memo(
  ({ token, range }) => {
    const getHistoricalPrices = useGetHistoricalPrices(token, range);
    const data = getHistoricalPrices.data || [];
    const changeValue =
      data.length > 1 ? data[data.length - 1].price - data[0].price : 0;
    const theme = useTheme();

    const sorted = data.sort((a, b) => Number(a.ts - b.ts));

    // If there's only one data point, duplicate it with a slightly different timestamp
    const adjustedData =
      sorted.length === 1
        ? [
            sorted[0],
            { ...sorted[0], ts: sorted[0].ts + BigInt(1_000_000) }, // Add 1 second
          ]
        : sorted;

    // Prepare the data for the chart
    const chartData = {
      labels: adjustedData.map(
        (entry) => new Date(Number(entry.ts / BigInt(1_000_000))),
      ), // Use Date objects for time scale
      datasets: [
        {
          data: adjustedData.map((entry) => entry.price),
          borderColor:
            changeValue >= 0
              ? theme.palette.success[400]
              : theme.palette.danger[400],
          pointRadius: 0, // Disable the circles around each point
          borderWidth: 2,
        },
      ],
    };

    // Determine the time unit and display formats based on the range
    let timeUnit: string;
    let displayFormats: { [key: string]: string };

    switch (range) {
      case 'hour':
        timeUnit = 'minute';
        displayFormats = { minute: 'HH:mm' }; // Format for minute labels
        break;
      case 'day':
        timeUnit = 'hour';
        displayFormats = { hour: 'HH:mm' }; // Format for hour labels
        break;
      default:
        timeUnit = 'day';
        displayFormats = { month: 'MMM yyyy', day: 'MMM dd' }; // Formats for month and day labels
        break;
    }

    // Configure the chart options
    const options = {
      responsive: true,
      plugins: {
        legend: {
          display: false, // Disable the legend
        },
      },
      scales: {
        x: {
          type: 'time', // Use time scale
          time: {
            unit: timeUnit, // Set the unit dynamically
            displayFormats: displayFormats, // Set display formats dynamically
            tooltipFormat: 'PP', // Format for tooltips
          },
          ticks: {
            maxRotation: 0,
            autoSkip: true,
          },
        },
        y: {
          ticks: {
            callback: function (value: number) {
              // Format the value as a dollar amount with 2 to 6 decimal places
              return `$${value.toLocaleString(undefined, {
                minimumFractionDigits: 0,
                maximumFractionDigits: 4,
              })}`;
            },
          },
        },
      },
    };

    return (
      <Box>
        <Line data={chartData} options={options as any} height={100} />
      </Box>
    );
  },
);

export default TokenPriceChart;
