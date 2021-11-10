// SPDX-License-Identifier: GPL-3.0

// Created by AbhayRana 
// The Awesome Nfts

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";  //this is the openzapplin libraries
import "@openzeppelin/contracts/access/Ownable.sol";

contract Awesome Nfts is ERC721Enumerable, Ownable {                 //contract Name is NErdyCoderCLone and inherited from the openzaplin libraries
  using Strings for uint256;                                             //convert only uint 256 to the addresses

  string public baseURI;                                                //base url is the link of the where you hosted your metadata
  string public baseExtension = ".json";                               //this is add in the end of the filenumber like 1.json ,2.json 
  uint256 public cost = 100 ether;                                      //amouont of each nft in ether if this in polygon so it also works as same but in matic (native ) token 
  uint256 public maxSupply = 1000;                                    //upper capp of the maximum amount of the nft can be minted
  uint256 public maxMintAmount = 20;                                     //user can not mint more than 20 nft per session 
  bool public paused = false;                                      //if we want to stop the minting it is like play and pause button
  mapping(address => bool) public whitelisted;                      //the community member whom we want to gi9vewaway sopme nt freee os cost

  constructor(                                                     //when you deply the contract first time so give this fdetails
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    mint(msg.sender, 20);                                         //rewar6ds with the 20nft to the deployer of the contract free of cpst
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;                                                //returns the base url of the hosted service
  }

  // public
  function mint(address _to, uint256 _mintAmount) public payable {            //  mint the nft to the this address
    uint256 supply = totalSupply();                                           // workslike a counter *(circulation supply)
    require(!paused);                                                   
    require(_mintAmount > 0);                                                //user shouldmint more than 1 nft
    require(_mintAmount <= maxMintAmount);                                    //mint amount should be less than per session minitng
    require(supply + _mintAmount <= maxSupply);                             //counter + user minitng amount of nft should be less than upper caps of the maximum supply 

    if (msg.sender != owner()) {                                                    //if the caller is not the owner 
        if(whitelisted[msg.sender] != true) {                                      //if the caller is notr the whitelisted
          require(msg.value >= cost * _mintAmount);                                 // check the user giving the money more than the cost of each nft * minitng nft 
        }
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {                                //mint the nft to the caller account
      _safeMint(_to, supply + i);
    }
  }

  function walletOfOwner(address _owner)                            //user input the address of the other wallet and it returns the tokeid holding by the user
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

  function tokenURI(uint256 tokenId)                       //user input the token id and it returns the url of the tokenid
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

    string memory currentBaseURI = _baseURI();                          //join the baseurl + tokenid + baseextension 
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner                                //only owner can call this functions 
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
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

  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }
}
