// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    rinkeby: {
      host: "localhost", // Connect to geth on the specified
      port: 8546,
      from: "0x0c1A5e96679d1C7D82888641D5F2Df88108CE349", // default address to use for any transaction Truffle makes during migrations
      network_id: 4,
      gas: 4612388 // Gas limit used for deploys
    }
  }
}
