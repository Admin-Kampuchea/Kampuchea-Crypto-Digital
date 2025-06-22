// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KampucheaCoin is ERC20, ERC20Burnable, Pausable, Ownable {

    mapping(address => bool) private _blacklist;

    event BlacklistUpdated(address indexed user, bool value);

    constructor() ERC20("Kampuchea Coin", "KHC") {
        // ចំនួនចាប់ផ្តើម 100,000,000,000 KHC (18 decimals)
        _mint(msg.sender, 100_000_000_000 * 10 ** decimals());
    }

    // បញ្ឈប់បន្ថែម Token (mint) អ្នកម្ចាស់អាចប្រើ
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // បិទបើក transfer ប្រើ Pause
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // Add/remove blacklist user
    function setBlacklist(address user, bool value) external onlyOwner {
        _blacklist[user] = value;
        emit BlacklistUpdated(user, value);
    }

    function isBlacklisted(address user) public view returns (bool) {
        return _blacklist[user];
    }

    // Override _beforeTokenTransfer ដើម្បីចាក់ pause និង blacklist
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {
        require(!isBlacklisted(from), "KHC: sender blacklisted");
        require(!isBlacklisted(to), "KHC: recipient blacklisted");
        super._beforeTokenTransfer(from, to, amount);
    }
}