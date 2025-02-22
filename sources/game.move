module kamkam::game;

use std::string::{String};
use kamkam::comment::{Self}; 
use kamkam::utils::{to_b36};
use sui::event::{emit};

const EALREADY_COMMENTED:u64 = 0;

public struct Game has key, store {
    id: UID,
    name: String,
    total_score: u64, // The total score of the game
    num_comments: u64, // The number of comments of the game
    average_score: u64, // The average score of the game
    comments: vector<address>, // The comments of the game
    blob: String,
    b36string: String
} 

public struct Event_GameAdded has copy, drop {
    id: ID,
    name: String,
    b36string: String,
}

public fun new (ctx: &mut TxContext, blob_id: String, name: String) : Game{
    let id =  object::new(ctx);
    let object_address = object::uid_to_address(&id);
    let b36string = to_b36(object_address);
    let event_id =  id.to_inner();

    let game = Game {
        id,
        name,
        total_score: 0,
        num_comments: 0,
        average_score: 0,
        comments: vector::empty(),
        blob: blob_id,
        b36string: b36string
    };

    emit(Event_GameAdded{
        id: event_id,
        name: name,
        b36string: b36string
    });

    game
}

public fun get_address_from_game(game: &Game): address {
    game.id.to_address()
}

#[allow(lint(self_transfer))]
public fun add_comment(ctx: &mut TxContext, game: &mut Game, text: String, score: u64) {
    let game_id = game.id.to_inner();
    let comment = comment::new(ctx, game_id, score, text);
    let comment_address = comment.get_address_from_comment();
    assert!(!game.comments.contains(&comment_address), EALREADY_COMMENTED);

    let comment_score = comment.get_score();
    game.total_score = comment_score + game.total_score;
    game.num_comments = game.num_comments + 1;
    game.average_score = game.total_score / game.num_comments;
    transfer::public_transfer(comment, ctx.sender());
    game.comments.push_back(comment_address);
}

