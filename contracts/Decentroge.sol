// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Decentroge is ERC721URIStorage {
    // uint256 public folderId;
    // uint256 public fileId;
    address payable owner;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    uint256 public userCount = 0;
    uint256 listingPrice = 0.025 ether;

    // uint256 public platformCount = 0;

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        string name;
        string description;
        string image;
    }

    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold,
        string name,
        string description,
        string image
    );

    struct File {
        uint256 fileId;
        uint256 fileCount;
        string fileHash;
        uint256 fileSize;
        string fileType;
        string fileName;
        uint256 folderId;
        string fileDescription;
        uint256 uploadTime;
        address sender;
    }

    struct Folder {
        //platform id needed
        uint256 platformId;
        uint256 folderCount;
        uint256 id;
        string folderName;
        File files;
        address owner;
    }

    struct Platform {
        string platformName;
        string token;
        uint256 platform_id;
        string platformid;
        string platformsecret;
        uint256 platformCount;
        address user;
    }

    struct User {
        uint256 id;
        address payable _address;
        string image;
        string profile;
        uint256 balance;
    }
    event FolderCreated(uint256 indexed _id, string foldername);
    event FileCreated(
        uint256 indexed fileId,
        uint256 fileCount,
        string fileHash,
        uint256 fileSize,
        string fileType,
        string fileName,
        uint256 folderId,
        string fileDescription,
        uint256 uploadTime,
        address sender
    );
    event UserCreated(
        uint256 id,
        address payable _address,
        string image,
        string profile,
        uint256 balance
    );

    mapping(address => mapping(uint256 => Platform)) public platform;
    mapping(address => mapping(uint256 => Folder)) public folder;
    mapping(address => bool) public registeredUsers;

    mapping(address => uint256) folderCount;
    mapping(address => mapping(uint256 => uint256)) fileCount;
    mapping(address => uint256) platformCount;
    mapping(uint256 => mapping(uint256 => File)) file;
    mapping(uint256 => User) users;
    mapping(address => User) userProfile;

    constructor() ERC721("Metaverse Tokens", "METT") {
        owner = payable(msg.sender);
    }

    function addPlatform(
        string memory _platformName,
        string memory token,
        string memory _projectid,
        string memory _projectsecret
    ) external {
        platformCount[msg.sender] = platformCount[msg.sender] + 1;
        Platform storage _platform = platform[msg.sender][
            platformCount[msg.sender]
        ];
        // require(
        //     keccak256(abi.encodePacked(_platform.platformName)) ==
        //         keccak256(abi.encodePacked(_platformName)),
        //     "Platform name already exisits"
        // );
        _platform.platformName = _platformName;
        _platform.token = token;
        _platform.platform_id = platformCount[msg.sender];
        _platform.platformCount = platformCount[msg.sender];
        _platform.platformid = _projectid;
        _platform.platformsecret = _projectsecret;
        _platform.user = msg.sender;
        platform[msg.sender][platformCount[msg.sender]] = _platform;
    }

    function createProfile(string memory _image, string memory _profile)
        public
    {
        if (registeredUsers[msg.sender] == false) {
            userCount++;
            User storage _users = users[userCount];
            User storage _userprofile = userProfile[msg.sender];

            _users.id = userCount;
            _users._address = payable(address(msg.sender));
            _users.image = _image;
            _users.profile = _profile;
            _users.balance = 0;
            registeredUsers[msg.sender] = true;

            //userProfile
            _userprofile.id = userCount;
            _userprofile.image = _image;
            _userprofile.profile = _profile;
            _userprofile._address = payable(address(msg.sender));

            userProfile[msg.sender] = _userprofile;
            users[userCount] = _users;

            emit UserCreated(
                _users.id,
                payable(address(msg.sender)),
                _image,
                _profile,
                _users.balance
            );
        }
    }

    //without validdation
    function createFolder(string memory _foldername, uint256 _platformId)
        public
    {
        folderCount[msg.sender] = folderCount[msg.sender] + 1;
        Folder storage _folder = folder[msg.sender][folderCount[msg.sender]];
        // require(
        //     _folder.platformId == _platformId &&
        //         keccak256(abi.encodePacked(_folder.folderCount)) ==
        //         keccak256(abi.encodePacked(_foldername)),
        //     "Folder name already exisits"
        // );

        _folder.id = folderCount[msg.sender];
        _folder.folderCount = folderCount[msg.sender];
        _folder.folderName = _foldername;
        _folder.platformId = _platformId;
        _folder.owner = msg.sender;
        folder[msg.sender][folderCount[msg.sender]] = _folder;
        emit FolderCreated(_folder.folderCount, _foldername);
    }

    function addFiles(
        uint256 _folderId,
        string memory _fileHash,
        uint256 _fileSize,
        string memory _fileType,
        string memory _fileName,
        string memory _fileDescription
    ) public {
        require(bytes(_fileHash).length > 0);

        require(bytes(_fileType).length > 0);

        // require(bytes(_fileDescription).length > 0);

        require(bytes(_fileName).length > 0);

        require(_fileSize > 0);
        fileCount[msg.sender][_folderId] = fileCount[msg.sender][_folderId] + 1;

        File storage _file = file[_folderId][fileCount[msg.sender][_folderId]];
        // require(
        //     _file.folderId == _folderId &&
        //         keccak256(abi.encodePacked(_file.fileName)) ==
        //         keccak256(abi.encodePacked(_fileName)),
        //     "Folder name already exisits"
        // );
        _file.fileId = fileCount[msg.sender][_folderId];
        _file.fileCount = fileCount[msg.sender][_folderId];
        _file.fileHash = _fileHash;
        _file.fileSize = _fileSize;
        _file.fileType = _fileType;
        _file.fileName = _fileName;
        _file.folderId = _folderId;
        _file.fileDescription = _fileDescription;
        _file.uploadTime = block.timestamp;
        _file.sender = msg.sender;
        file[_folderId][fileCount[msg.sender][_folderId]] = _file;
        emit FileCreated(
            _file.fileId,
            _file.fileCount,
            _file.fileHash,
            _file.fileSize,
            _file.fileType,
            _file.fileName,
            _folderId,
            _file.fileDescription,
            _file.uploadTime,
            msg.sender
        );
    }

    //  my platforms
    function getPlatforms() public view returns (Platform[] memory) {
        uint256 itemCount = platform[msg.sender][platformCount[msg.sender]]
            .platformCount;
        uint256 currentIndex = 0;
        Platform[] memory _platform = new Platform[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            Platform storage currentItem = platform[msg.sender][currentId];
            _platform[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return _platform;
    }

    //get folders
    function getFolders(uint256 _platformId)
        public
        view
        returns (Folder[] memory)
    {
        uint256 itemCount = folder[msg.sender][folderCount[msg.sender]]
            .folderCount;
        uint256 currentIndex = 0;
        Folder[] memory _folder = new Folder[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (folder[msg.sender][i + 1].platformId == _platformId) {
                uint256 currentId = i + 1;
                Folder storage currentItem = folder[msg.sender][currentId];
                _folder[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return _folder;
    }

    //get files
    function getFiles(uint256 _folderId) public view returns (File[] memory) {
        uint256 itemCount = file[_folderId][fileCount[msg.sender][_folderId]]
            .fileCount;
        uint256 currentIndex = 0;
        File[] memory _file = new File[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            File storage currentItem = file[_folderId][currentId];
            _file[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return _file;
    }

    //get users
    function fetchAllUsers() public view returns (User[] memory) {
        uint256 itemCount = userCount;
        uint256 currentIndex = 0;
        User[] memory items = new User[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            User storage currentItem = users[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return items;
    }

    //get registered user
    function isRegistered() public view returns (bool) {
        if (registeredUsers[msg.sender] == true) {
            return true;
        } else {
            return false;
        }
    }

    //get user
    function getSingleUser() public view returns (User memory) {
        return userProfile[msg.sender];
    }

    //tipUser
    function tipUser(uint256 id) public payable {
        User storage _users = users[id];
        _users._address.transfer(msg.value);
        _users.balance = _users.balance + msg.value;
        users[id] = _users;
    }

    //NFT functions

    /* Updates the listing price of the contract */
    function updateListingPrice(uint256 _listingPrice) public payable {
        require(
            owner == msg.sender,
            "Only marketplace owner can update listing price."
        );
        listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Mints a token and lists it in the marketplace */
    function createToken(
        string memory tokenURI,
        uint256 price,
        string memory _name,
        string memory _description,
        string memory _image
    ) public payable returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price, _name, _description, _image);
        return newTokenId;
    }

    function createMarketItem(
        uint256 tokenId,
        uint256 price,
        string memory _name,
        string memory _description,
        string memory _image
    ) private {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false,
            _name,
            _description,
            _image
        );

        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false,
            _name,
            _description,
            _image
        );
    }

    /* allows someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(
            idToMarketItem[tokenId].owner == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 tokenId) public payable {
        uint256 price = idToMarketItem[tokenId].price;
        address seller = idToMarketItem[tokenId].seller;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );
        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0));
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
        payable(seller).transfer(msg.value);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items a user has listed */
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
