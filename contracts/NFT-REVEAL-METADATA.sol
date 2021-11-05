// SPDX-License-Identifier: GPL-3.0

// by Abhay Rana

//in this we are going to set the nft metadata to a placeholder we hide our nft and we disclosed our nft when all the nft is sell or particular condintions met 
//owner can set the reveal function true/false according to him 
//remeber opensea takes sometime to reflect refresh the nft/art in opensea 

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";    //openzaplin library
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.05 ether;                               //price of one nft
  uint256 public maxSupply = 10000;                                //hard cap of max supply of nft collection
  uint256 public maxMintAmount = 20;                                //max nft can minted by the minter  
  bool public paused = false;
  bool public revealed = false;                                       //REVEAL IS FALSE IT MEANS BY DEFAULT MINTER CANT SEE THE NFT UNTIL AND UNLESS DEPLOYER/OWNER NOT SET THE REVEAL==TRUE
  string public notRevealedUri;                                       //METADATA OF THE HIDDEN NFT / MEANS THE PLACEHOLDER HAVE ITS OWN MEATADATA
  mapping(address => bool) public whitelisted;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri                               //URL OF PLACEHOLDER TAKEN WHILE THE DEPLOYMENT OF THE PROJECT
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);                         //SETTING OF URL OF THE PLACEHILDER METADATA
    mint(msg.sender, 20);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(address _to, uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);

    if (msg.sender != owner()) {
        if(whitelisted[msg.sender] != true) {
          require(msg.value >= cost * _mintAmount);
        }
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(_to, supply + i);
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
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
    
    if(revealed == false) {                           //IF THE REVEAL IS FALSED RETURN THE PLACEHOLDER URL FOR ALL THE NFT MINTED TILL DATE
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();         //IF THE REVEAL IS TRUE THEN SHOW ITS ACTUAL METADATA
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {              //OWNER CAN SET THE NEW PLACEHOLDER URLOF THE NFT 
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
 function whitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = true;
  }
 
  function removeWhitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = false;
  }

  function withdraw() public payable onlyOwner {                  //WITHDRAW THE AMOUNT OF THE SC COLLECTED BY THE LAZY MINTING 
    // This will pay HashLips 5% of the initial sale.               //THANKS TO THE HASHLIPS FOR MAKIG THIS HAPPEN 
    // You can remove this if you want, or keep it in to support HashLips and his channel.
    // =============================================================================
    (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 5 / 100}("");
    require(hs);
    // =============================================================================
    
    // This will payout the owner 95% of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }
}
