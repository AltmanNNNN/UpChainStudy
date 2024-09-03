pragma solidity ^0.8.2;


contract RNTMarket is EIP712{

    bytes32 ORDER_TYPE_HASH = keccak256("RentoutOrder(address maker,address nft_ca,uint256 token_id,uint256 daily_rent,uint256 max_rental_duration,uint256 min_collateral,uint256 list_endtime)");
    

    event BorrowNFT(address indexed maker, address indexed taker, address indexed nft_ca, uint256 token_id, uint256 daily_rent, uint256 max_rental_duration, uint256 min_collateral, uint256 list_endtime, uint256 start_time, uint256 collateral);
    event OrderCanceled(address indexed maker, address indexed nft_ca, uint256 token_id, uint256 list_endtime);

    mapping(bytes32 => bool) public canceledOrders; //已取消订单
    mapping(bytes32 => BorrowOrder) public borrowOrders; //已租赁订单

    constructor() EIP712("RentNFTMarket", "1"){
    }

    function borrow(RentoutOrder calldata order, bytes calldata makerSignature) external payable{
        require(block.timestamp < order.list_endtime, "order expired");
        require(order.min_collateral > 0, "collateral must be greater than 0");
        require(msg.value >= order.min_collateral, "collateral not enough");
        require(order.maker != msg.sender, "can't borrow from yourself");

        bytes32 hash = orderHash(order);
        
        require(borrowOrders[hash].taker == address(0), "order already borrowed");
        require(!canceledOrders[hash], "order canceled");
        //验证签名 验证 orderID 对应的签名地址是否是 maker
        address signer = ECDSA.recover(hash, makerSignature);
        require(signer == order.maker, "invalid signature");

        //存储订单
        borrowOrders[hash] = BorrowOrder({
            taker: msg.sender,
            collateral: msg.value,
            start_time: block.timestamp,
            rentinfo: order
        });       

        //转移NFT所有权
        IERC721(order.nft_ca).transferFrom(order.maker, msg.sender, order.token_id); 
        emit BorrowNFT(order.maker, msg.sender, order.nft_ca, order.token_id, order.daily_rent, order.max_rental_duration, order.min_collateral, order.list_endtime, block.timestamp, msg.value);
    }

    function canceledOrder(RentoutOrder calldata order, bytes calldata makerSignature) external{
        require(order.maker == msg.sender, "only maker can cancel order");
        bytes32 hash = orderHash(order);
        require(!canceledOrders[hash], "order already canceled");
        address signer = ECDSA.recover(hash, makerSignature);
        require(signer == order.maker, "invalid signature");
        canceledOrders[hash] = true;
        emit OrderCanceled(order.maker, order.nft_ca, order.token_id, order.list_endtime);
    }

    function orderHash(RentoutOrder calldata order) public pure returns(bytes32){
        return _hashTypedDataV4(keccak256(abi.encode(
            ORDER_TYPE_HASH,
            order.maker,
            order.nft_ca,
            order.token_id,
            order.daily_rent,
            order.max_rental_duration,
            order.min_collateral,
            order.list_endtime
        )));
    }


    struct RentoutOrder{
        address maker;  //出租方地址
        address nft_ca; //nft合约
        uint256 token_id; //nft token id
        uint256 daily_rent; //每日租金
        uint256 max_rental_duration; //最大租赁时长
        uint256 min_collateral; //最小抵押
        uint256 list_endtime; //挂单结束时间
    }

    struct BorrowOrder{
        address taker; //租赁方地址
        uint256 collateral; //抵押
        uint256 start_time; //开始时间 
        RentoutOrder rentinfo; //租赁信息
    }

}
