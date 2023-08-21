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

    event ShelterAdded(
        uint256 shelterId,
        string shelterName,
        string shelterCountry,
        string shelterCity,
        string shelterZipCode,
        bool atCapacity,
        address shelterOwner,
        bool isDeleted
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
        string shelterCountry;
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
        string memory _shelterCountry,
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
        emit ShelterAdded(
            totalShelterId,
            _shelterName,
            _shelterCountry,
            _shelterCity,
            _shelterZipCode,
            false,
            msg.sender,
            false
        );
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

    function updateShelterCapacity(
        uint256 _shelterId,
        bool _newCapacity
    )
        public
        onlyExistingShelter(_shelterId)
        onlyNotDeletedShelter(_shelterId)
        onlyShelterOwner(_shelterId)
    {
        Shelter storage shelter = ShelterListings[_shelterId];
        shelter.atCapacity = _newCapacity;
    }

    function updateShelterStatus(
        uint256 _shelterId,
        bool _isDeleted
    ) public onlyExistingShelter(_shelterId) onlyShelterOwner(_shelterId) {
        Shelter storage shelter = ShelterListings[_shelterId];
        shelter.isDeleted = _isDeleted;
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