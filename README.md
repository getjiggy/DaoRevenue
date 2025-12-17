### Dao Revenue

This is an unaudited, experimental repo designed to help dao's direct onchain revenue to token holders/dao treasury. The idea is the RevenueReceiver contract is designated as the address receiving any onchain revenue generated from a protocol. This revenue is then split between a dividend distribution contract and the dao treasury receiver contract. 

Currently, the project is relatively naive. It only allows for splitting on chain revenue between the treasury and dividend distribution contract. holders of the dao's token can claim the dividend payments on a per share basis.

As I continue to have free time to work on this, i plan to evolve the architecture and contracts so that options exist for a buy/burn mechanic, an easily cross chain compatabile receiver extension, and other features as I think they are interesting. 

This is repo is purely for fun/learning, as I plan to write both traditional unit tests/fuzz tests but to also learn the ins and out of symbolic testing with halmos etc. 

Should go without saying DO NOT USE THESE IN PRODUCTION. 
```
╭--------------------------------+------------------+------------------+----------------+----------------╮
| File                           | % Lines          | % Statements     | % Branches     | % Funcs        |
+========================================================================================================+
| src/DividendDistributor.sol    | 84.62% (33/39)   | 88.64% (39/44)   | 58.33% (7/12)  | 83.33% (5/6)   |
|--------------------------------+------------------+------------------+----------------+----------------|
| src/RevenueReceiver.sol        | 90.48% (19/21)   | 94.74% (18/19)   | 100.00% (4/4)  | 75.00% (3/4)   |
|--------------------------------+------------------+------------------+----------------+----------------|
| src/RevenueSplitter.sol        | 95.83% (23/24)   | 96.30% (26/27)   | 71.43% (5/7)   | 100.00% (3/3)  |
|--------------------------------+------------------+------------------+----------------+----------------|
| test/TestBase.sol              | 100.00% (14/14)  | 100.00% (13/13)  | 100.00% (0/0)  | 100.00% (2/2)  |
|--------------------------------+------------------+------------------+----------------+----------------|
| test/utils/DividendHandler.sol | 83.33% (25/30)   | 82.76% (24/29)   | 100.00% (3/3)  | 60.00% (3/5)   |
|--------------------------------+------------------+------------------+----------------+----------------|
| test/utils/MockErc20.sol       | 100.00% (2/2)    | 100.00% (1/1)    | 100.00% (0/0)  | 100.00% (1/1)  |
|--------------------------------+------------------+------------------+----------------+----------------|
| test/utils/MockFeeErc20.sol    | 68.42% (13/19)   | 65.00% (13/20)   | 50.00% (1/2)   | 75.00% (3/4)   |
|--------------------------------+------------------+------------------+----------------+----------------|
| Total                          | 86.58% (129/149) | 87.58% (134/153) | 71.43% (20/28) | 80.00% (20/25) |
╰--------------------------------+------------------+------------------+----------------+----------------╯
```