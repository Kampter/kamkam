module template::game;

use std::string::{String};
use sui::clock::{Clock};
use template::comment::{Self};

public struct Game has key, store {
    id: UID,
    name: String,
    total_score: u64, // The total score of the game
    num_comments: u64, // The number of comments of the game
    average_score: u64, // The average score of the game
    comments: vector<address>, // The comments of the game
}

public fun new (ctx: &mut TxContext, name: String): Game {
    Game {
        id: object::new(ctx),
        name,
        total_score: 0,
        num_comments: 0,
        average_score: 0,
        comments: vector::empty(),
    }
}

public fun get_address_from_game(game: &Game): address {
    game.id.to_address()
}

#[allow(lint(self_transfer))]
public fun add_comment(ctx: &mut TxContext, game: &mut Game, text: String, score: u64, clock: &Clock) {
    let game_id = game.id.to_inner();
    let comment = comment::new(ctx, game_id, clock, score, text);
    let comment_address = comment.get_address_from_comment();
    let comment_score = comment.get_score();
    game.total_score = comment_score + game.total_score;
    game.num_comments = game.num_comments + 1;
    game.average_score = game.total_score / game.num_comments;
    transfer::public_transfer(comment, ctx.sender());
    game.comments.push_back(comment_address);
}

