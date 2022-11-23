// // Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract Stust_NFT_meta is ERC721Enumerable, Ownable{
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter public _items;
    Counters.Counter private _tokenIds;
    Counters.Counter private _soldItems;
    Counters.Counter private _nftCount;
    Counters.Counter private _nftsSold;
    bool public _isSaleActive = true;//開啟公售
    bool public _revealed = false;

    // Constants
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public mintPrice = 0.003 ether;
    uint256 public maxBalance =10;
    uint256 public maxMint =10;
    
    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";
    mapping(uint256 => MarketplaceItem) public idToMarketplaceItem;
    mapping(uint256 => string) public _tokenURIs;
    mapping(uint256 => MarketplaceItem) private _idToNFT;
    mapping(uint256 => address)public tokenIdToaddress;
    struct MarketplaceItem {
        uint256 itemId;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    event MarketplaceItemCreated(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    event NFTMinted(uint256);
    
    constructor(string memory initBaseURI, string memory initNotRevealedUri)
        ERC721("Stust NFT meta", "SNM")
    {
        setBaseURI(initBaseURI);
        setNotRevealedURI(initNotRevealedUri);
    }

    function mintSNMeta(uint256 tokenQuantity) public payable {
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        require(_isSaleActive, "Sale must be active to mint SNMetas");
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether sent"
        );
        require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");
       
        _mintSNMeta(tokenQuantity);

    }

    function _mintSNMeta(uint256 tokenQuantity) internal {
        
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
                tokenIdToaddress[mintIndex]=msg.sender;
                _tokenIds.increment();
            }
        }
    }

    function getMintPrice() public view returns (uint256) {
        return mintPrice;
    }
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (_revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public  {
        _revealed = !_revealed;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public  {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public  {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }

    function createMarketplaceItem(
        uint256 tokenId,
        uint256 price
    ) public payable{
        _items.increment();
        uint256 itemId = _items.current();

        idToMarketplaceItem[itemId] = MarketplaceItem(
            itemId,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);

        emit MarketplaceItemCreated(
            itemId,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }
    function createMarketplaceSale( uint256 itemId)
        public
        payable
    {
        uint256 price = idToMarketplaceItem[itemId].price;
        uint256 tokenId = idToMarketplaceItem[itemId].tokenId;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );
        

        idToMarketplaceItem[itemId].seller.transfer(msg.value);
        _transfer(address(this), msg.sender, tokenId);
        idToMarketplaceItem[itemId].owner = payable(msg.sender);
        idToMarketplaceItem[itemId].sold = true;
        tokenIdToaddress[tokenId]=msg.sender;

        _soldItems.increment();
    }
         function fetchMarketplaceItems()
        public
        view
        returns (MarketplaceItem[] memory)
    {
        uint256 itemCount = _items.current();
        uint256 unsoldItemCount = _items.current() - _soldItems.current();
        uint256 currentIndex = 0;

        MarketplaceItem[] memory items = new MarketplaceItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketplaceItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketplaceItem storage currentItem = idToMarketplaceItem[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
    function fetchMyNFTs() public view returns (uint256[] memory) {
        uint256 totalIdCount = _tokenIds.current();
        uint256 tokenCount=0;
        uint256 currentIndex = 0;
        for(uint256 i=0;i<= totalIdCount;i++){
            if(tokenIdToaddress[i]==msg.sender){
                tokenCount+=1;
            }
        }
        uint256[] memory myTokenIds=new uint256[](tokenCount);
        for(uint256 i=0;i<=totalIdCount;i++){
            if(tokenIdToaddress[i]==msg.sender){
                myTokenIds[currentIndex]=i;
                currentIndex+=1;
            }
        }
        return myTokenIds;
    }
    function fetchItemsCreated()
        public
        view
        returns (MarketplaceItem[] memory)
    {
        uint256 totalItemCount = _items.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketplaceItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketplaceItem[] memory items = new MarketplaceItem[](itemCount);

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketplaceItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketplaceItem storage currentItem = idToMarketplaceItem[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    
}

