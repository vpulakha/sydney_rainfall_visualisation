# sydney_rainfall_visualisation
# Sydney Rainfall Visualisation from 1900 to 2022

2022 has been an extraordinarily wet year in Sydney and I wanted to understand how the rainfall data of 2022 compares to the historical data maintained by the Australian Bureau of Meteorology (BOM) (http://www.bom.gov.au/). The BOM allows you to download weather related data going all the way back to 1850's.

The visualisation is generated using R along with some basic packages:

1. data.table for data manipulation
2. ggplot2 for visualisation
3. ggrepel for text annotation
4. ggthemes for managing the background of the chart

With a few lines of ggplot, we see see 122 years (from 1900 - 2022) of data in a simple chart.  

<img width="905" alt="image" src="https://user-images.githubusercontent.com/109650950/194330884-c0e61ca3-1b6b-4392-9167-09735be181fb.png">
