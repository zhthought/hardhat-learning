const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const JAN_1ST_2030 = 1893456000;
const ONE_GWEI = 1_000_000_000n;



module.exports = buildModule("mm314Module", (m) => {
  const unlockTime = m.getParameter("unlockTime", JAN_1ST_2030);
  const lockedAmount = m.getParameter("lockedAmount", ONE_GWEI);

  const mm314 = m.contract("mm314", [100000000, 10000000], {
    value: ONE_GWEI * ONE_GWEI / 100n, // 0.01eth
    gasPrice: 21000,
  });

  return { mm314 };
});
