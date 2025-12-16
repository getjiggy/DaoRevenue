### Dao Revenue

This is an unaudited, experimental repo designed to help dao's direct onchain revenue to token holders/dao treasury. The idea is the RevenueReceiver contract is designated as the address receiving any onchain revenue generated from a protocol. This revenue is then split between a dividend distribution contract and the dao treasury receiver contract. 

Currently, the project is relatively naive. It only allows for splitting on chain revenue between the treasury and dividend distribution contract. holders of the dao's token can claim the dividend payments on a per share basis.

As I continue to have free time to work on this, i plan to evolve the architecture and contracts so that options exist for a buy/burn mechanic, an easily cross chain compatabile receiver extension, and other features as I think they are interesting. 

This is repo is purely for fun/learning, as I plan to write both traditional unit tests/fuzz tests but to also learn the ins and out of symbolic testing with halmos etc. 

Should go without saying DO NOT USE THESE IN PRODUCTION. 