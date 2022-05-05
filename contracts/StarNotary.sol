pragma solidity >=0.8.4;

//Importing openzeppelin-solidity ERC-721 implemented Standard
// import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// StarNotary Contract declaration inheritance the ERC721 openzeppelin implementation
contract StarNotary is ERC721 {

    // Star data
    struct Star {
        string name;
    }

    constructor() ERC721("Jacks Udacity Token", "JUT"){}

    // string public constant name = 'Jacks Udacity Token';
    // string public constant symbol = 'JUT';
    

    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;

    
    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    // function _make_payable(address x) internal pure returns (address payable) {
    //     return address(uint160(x));
    // }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        transferFrom(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            address payable msgSenderPayable = payable(msg.sender);
            msgSenderPayable.transfer(msg.value - starCost);
        }
    }

    // Look up Token
    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        Star memory returnStar = tokenIdToStarInfo[_tokenId];
        return returnStar.name;
    }

    // Exchange Stars
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        address owner1Address = ownerOf(_tokenId1);
        address owner2Address = ownerOf(_tokenId2);
        require(owner1Address == msg.sender || owner2Address == msg.sender, "Only the owners are allowed to exchange stars");
        _transfer(owner1Address, owner2Address, _tokenId1);
        _transfer(owner2Address, owner1Address, _tokenId2);
    }

    // Transfer Stars
    function transferStar(address _to1, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "You need to be the token owner");
        transferFrom(msg.sender, _to1, _tokenId);
    }
}