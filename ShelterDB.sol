// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract ShelterDB {
    /**
     * Shelters often struggle to accommodate the constant influx of new animals.
     * This overcrowding leads to limited space for each animal,
     * which can result in health issues and a decreased quality of life.
     * This smart contract aims to support shelters by providing a decentralized database
     * that can track the population of animals in shelters.
     * This can help shelters better allocate resources and make informed decisions about
     * admitting new animals.
     */

    uint256 public totalPets;
    uint256 public totalShelterId; // every time a new shelter is added, this number increases

    enum Country {
        USA,
        India,
        Brazil
    }

    event ShelterInfo(
        uint256 shelterId,
        Country indexed shelterCountry,
        bool indexed atCapacity,
        bool indexed isDeleted
    );

    struct Pet {
        string name;
        string petType; // cat, dog, bird, other
        string size; // small, medium, large
        string sex; // female, male
        string age; // baby, young, adult, senior
        uint256 petId;
    }

    struct Shelter {
        string shelterName;
        Country shelterCountry;
        string shelterCity;
        string shelterZipCode;
        bool atCapacity;
        address shelterOwner;
        bool isDeleted;
    }

    mapping(uint256 => Pet[]) ShelterPets;
    mapping(uint256 => mapping(uint256 => bool)) PetIdExists;
    mapping(uint256 => Shelter) public ShelterListings;

    error ShelterNotAvaliable();
    error SheleterDeleted();
    error NotShelterOwner();
    error PetIdAlreadyTaken();

    modifier onlyExistingShelter(uint256 _shelterId) {
        if (_shelterId > totalShelterId || _shelterId == 0) {
            revert ShelterNotAvaliable();
        }
        _;
    }

    modifier onlyNotDeletedShelter(uint256 _shelterId) {
        if (ShelterListings[_shelterId].isDeleted == true) {
            revert SheleterDeleted();
        }
        _;
    }

    modifier onlyShelterOwner(uint256 _shelterId) {
        if (ShelterListings[_shelterId].shelterOwner != msg.sender) {
            revert NotShelterOwner();
        }
        _;
    }

    modifier onlyAvailablePetId(uint256 _shelterId, uint256 _petId) {
        if (PetIdExists[_shelterId][_petId]) {
            revert PetIdAlreadyTaken();
        }
        _;
    }

    constructor() {}

    function addShelter(
        string memory _shelterName,
        Country _shelterCountry,
        string memory _shelterCity,
        string memory _shelterZipCode
    ) public {
        totalShelterId++;
        // update Shelter struct
        ShelterListings[totalShelterId] = Shelter({
            shelterName: _shelterName,
            shelterCountry: _shelterCountry,
            shelterCity: _shelterCity,
            shelterZipCode: _shelterZipCode,
            atCapacity: false,
            shelterOwner: msg.sender,
            isDeleted: false
        });

        emit ShelterInfo(totalShelterId, _shelterCountry, false, false);
    }

    function updateShelter(
        uint256 _shelterId,
        string memory _shelterName,
        Country _shelterCountry,
        string memory _shelterCity,
        string memory _shelterZipCode,
        bool _newCapacity,
        bool _isDeleted
    )
        public
        onlyExistingShelter(_shelterId)
        onlyNotDeletedShelter(_shelterId)
        onlyShelterOwner(_shelterId)
    {
        // Use a reference to the existing Shelter struct stored in the ShelterListings[_shelterId] mapping entry.
        // By using the storage keyword, the function updates the fields of the existing struct in place.
        // This approach is often more efficient in terms of gas costs because it modifies the existing storage slot
        // without replacing the entire struct.

        Shelter storage shelter = ShelterListings[_shelterId];
        shelter.shelterName = _shelterName;
        shelter.shelterCountry = _shelterCountry;
        shelter.shelterCity = _shelterCity;
        shelter.shelterZipCode = _shelterZipCode;
        shelter.atCapacity = _newCapacity;
        shelter.shelterOwner = msg.sender;
        shelter.isDeleted = _isDeleted;

        emit ShelterInfo(_shelterId, _shelterCountry, _newCapacity, _isDeleted);
    }

    function getShelterListing(
        uint256 _shelterId
    )
        public
        view
        onlyExistingShelter(_shelterId)
        onlyNotDeletedShelter(_shelterId)
        returns (Shelter memory)
    {
        return ShelterListings[_shelterId];
    }

    function addPet(
        uint256 _shelterId,
        string memory _name,
        string memory _petType, // cat, dog, bird, other
        string memory _size, // small, medium, large
        string memory _sex, // female, male
        string memory _age, // baby, young, adult, senior
        uint256 _petId
    )
        public
        onlyExistingShelter(_shelterId)
        onlyNotDeletedShelter(_shelterId)
        onlyShelterOwner(_shelterId)
        onlyAvailablePetId(_shelterId, _petId)
    {
        totalPets++;
        PetIdExists[_shelterId][_petId] = true;

        ShelterPets[_shelterId].push(
            Pet({
                name: _name,
                petType: _petType,
                size: _size,
                sex: _sex,
                age: _age,
                petId: _petId
            })
        );
    }

    function getShelterPets(
        uint256 _shelterId
    )
        public
        view
        onlyExistingShelter(_shelterId)
        onlyNotDeletedShelter(_shelterId)
        returns (Pet[] memory)
    {
        return ShelterPets[_shelterId];
    }
}
