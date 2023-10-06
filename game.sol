// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract Game {

    uint8 constant ROCK = 1;
    uint8 constant PAPER = 2;
    uint8 constant SCISSORS = 3;

    struct GameRecord {
        address player;
        uint8 playerMove;
        uint8 randomMove;
        bool isDraw;
        address winner;
        uint256 reward;
    }

    mapping(address => uint8) public choices;
    GameRecord[] public gameHistory;

    event GameResult(address indexed player, uint8 playerMove, uint8 randomMove, bool isDraw, address winner, uint256 reward);

    function play(uint8 choice) external payable {
        choices[msg.sender] = choice;

        uint8 randomMove = generateRandomMove();
        address winner = evaluate(msg.sender, randomMove);

        uint256 reward = 0;
        if (winner != address(0)) {
            reward = calculateReward(msg.value);
            payable(winner).transfer(reward);
        }

        GameRecord memory result = GameRecord({
            player: msg.sender,
            playerMove: choice,
            randomMove: randomMove,
            isDraw: choices[msg.sender] == randomMove,
            winner: winner,
            reward: reward
        });

        gameHistory.push(result);

        emit GameResult(msg.sender, choice, randomMove, choices[msg.sender] == randomMove, winner, reward);
    }

    function getGameHistory() external view returns (GameRecord[] memory) {
        return gameHistory;
    }

    function evaluate(address player, uint8 randomMove) internal view returns (address) {
        if (choices[player] == randomMove) {
            return address(0); // It's a draw
        }

        if (
            (choices[player] == ROCK && randomMove == PAPER) ||
            (choices[player] == PAPER && randomMove == SCISSORS) ||
            (choices[player] == SCISSORS && randomMove == ROCK)
        ) {
            return address(this); // Random player wins
        } else {
            return player; // Player wins
        }
    }

    function generateRandomMove() internal view returns (uint8) {
        return uint8(uint256(blockhash(block.number - 1)) % 3 + 1);
    }

    function calculateReward(uint256 wager) internal pure returns (uint256) {
        uint256 reward = wager * 2;
        return reward;
    }

    receive() external payable {}
}
