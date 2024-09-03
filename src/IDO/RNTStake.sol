pragma solidity ^0.8.2;

contract RNTStake{
    IERC20 public immutable RNT;

    uint256 public constant mintSeedPersecond = 1 * 1e18 / 1 days;  // 

    constructor(IERC20 _RNT){
        RNT = _RNT;
    }

    mapping(address => Stake) public stakes;
    struct Stake{
        uint256 amount;
        uint256 lastUpdate;
        uint256 debt;
    }

    function stake(uint256 amount) external before{
        require(amount > 0, "amount must be greater than 0");
        require(RNT.transferFrom(msg.sender, address(this), amount), "transfer failed");

        stakes[msg.sender].amount += amount;
    }

    function unstake(uint256 amount) external before{
        Stake storage stake = stakes[msg.sender];
        require(s.amount >= amount, "amount exceeds balance");

        s.amount -= amount;
        require(RNT.transfer(msg.sender, amount), "transfer failed");
    }

    modifier before() internal {
        _;
        Stake storage s = stakes[msg.sender];
        if (s.amount == 0) return;

        uint256 duration = block.timestamp - s.lastUpdate;

        uint256 interest = s.amount * duration * mintSeedPersecond;
        s.debt += interest;
        s.lastUpdate = block.timestamp;
    }

}