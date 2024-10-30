// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {Deployers} from "v4-core/test/utils/Deployers.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {HookMiner} from "../src/utils/HookMiner.sol";
import {Hook} from "../src/hooks/Hook.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";
import {Manager} from "../src/Manager.sol";
import {PoolModifyLiquidityTest} from "v4-core/src/test/PoolModifyLiquidityTest.sol";
import {RWA} from "../src/RWA.sol";
import {Swap} from "../src/Swap.sol";

contract ManagerTest is Test {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    string public constant APP_ID = "app_staging_482e634f656d2dfd3243bf8d49c4ab7d";
    string public constant ACTION_ID = "user-verification";
    bytes constant ZERO_BYTES = Constants.ZERO_BYTES;

    Manager public manager;

    PoolManager public poolManager;
    PoolSwapTest public swapRouter;
    PoolModifyLiquidityTest public modifyLiquidityRouter;

    function setUp() public {
        vm.startPrank(msg.sender);

        poolManager = new PoolManager(500000);
        swapRouter = new PoolSwapTest(poolManager);
        modifyLiquidityRouter = new PoolModifyLiquidityTest(poolManager);

        console2.log("msg.sender in setUp", msg.sender);
        manager = new Manager({
            _initialOwner: msg.sender,
            _appId: APP_ID,
            _actionId: ACTION_ID,
            _manager: poolManager,
            _swapRouter: swapRouter,
            _modifyLiquidityRouter: modifyLiquidityRouter
        });

        vm.deal(address(manager), Constants.MAX_UINT256);
        vm.deal(msg.sender, Constants.MAX_UINT256);
    }

    function testManagerSetup() public {
        // asset details params
        RWA.AssetDetails memory assetDetails = RWA.AssetDetails({
            legalDescription: "RWA",
            assetAddress: "123 Main St",
            geoJson: "123 Main St",
            parcelId: "123 Main St",
            legalOwner: "123 Main St",
            operatingAgreementHash: keccak256(abi.encodePacked("123 Main St")),
            debtToken: address(0),
            debtAmt: 0,
            foreclosed: false,
            manager: address(manager)
        });

        Manager.SetupParams memory params = Manager.SetupParams({
            name: "Test",
            symbol: "TEST",
            uri: "https://test.com",
            assetDetails: assetDetails,
            supply: 10_000_000_000 * 1e18
        });

        console2.log("msg.sender in testManager", msg.sender);

        PoolKey memory key = manager.setup(params);
        assert(Currency.unwrap(key.currency0) == address(0));
        assert(Currency.unwrap(key.currency1) != address(0));
    }
}
