pragma solidity ^0.8.2;

contract RNTIDO{
    event PreSale(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    uint256 public constant PRICE = 0.0001 ether;
    uint256 public constant SOFTCAP = 10 ether; // 最低募集额度
    uint256 public constant HARDCAP = 100 ether; // 最高募集额度
    uint256 public immutable END_TIME; // 7天后结束

    IERC20 public immutable RNT;
    
    uint256 public constant TOTAL_SUPPLY = PRICE * HARDCAP; // 总发行量
    uint256 public totalSold; // 总售出
    uint256 public totalRaised; // 总募集

    mapping(address => uint256) public preSaleAmount; // 用户购买数量

    constructor(IERC20 _RNT){
        RNT = _RNT;
        END_TIME = block.timestamp + 7 days;
    }

    function preSale(uint256 amount) payable external{
        //当前时间小于结束时间
        require(block.timestamp < END_TIME, "presale ended");
        //ether数量等于代币数量乘以价格
        require(msg.value == amount * PRICE, "invalid amount");
        require(totalRaised + msg.value <= HARDCAP, "hardcap reached");

        totalSold += amount;
        totalRaised += msg.value;
        preSaleAmount[msg.sender] += amount;

        require(RNT.balanceOf(address(this)) >= totalSold, "sold out");
        emit PreSale(msg.sender, amount);
    }

    function claim() external{
        require(block.timestamp >= END_TIME, "presale not ended");
        require(totalRaised >= SOFTCAP, "softcap not reached");

        uint256 amount = preSaleAmount[msg.sender];
        require(amount > 0, "no presale amount");

        uint256 share = totalSold / TOTAL_SUPPLY;
        uint256 claimAmount = share * amount;
        preSaleAmount[msg.sender] = 0;
        require(RNT.transfer(msg.sender, claimAmount), "transfer failed");
    }

    //募集失败 退款
    function refund() external{
        require(block.timestamp >= END_TIME, "presale not ended");
        require(totalRaised < SOFTCAP, "softcap reached");

        uint256 amount = preSaleAmount[msg.sender];
        require(amount > 0, "no presale amount");

        preSaleAmount[msg.sender] = 0;
        uint256 refundAmount = amount * PRICE;
        (bool ok) = msg.sender.call{value: refundAmount}("");
        require(ok, "refund failed");
    }

    //募集成功 提现
    function withdraw() external{
        require(block.timestamp >= END_TIME, "presale not ended");
        require(totalRaised >= SOFTCAP, "softcap reached");

        (bool ok) = msg.sender.call{value: totalRaised}("");
        require(ok, "refund failed");
    }

}