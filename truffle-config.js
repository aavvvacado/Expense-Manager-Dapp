const { version } = require("react");

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",   // no HTTP://, no caps
      port: 7545,
      network_id: 5777   // match Ganache's network ID
    }
  },
  contracts_directory : './contracts',
  compilers: {
    solc: {
      version: "0.8.19",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  db: {
    enabled: false
  }
}