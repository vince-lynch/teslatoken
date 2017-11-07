// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      from: "0x5ad856c4c5d542ba6580a29f9044b9598686b4f3",
      network_id: '*' // Match any network id
    }
  }
}
