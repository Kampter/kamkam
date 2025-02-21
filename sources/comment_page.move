/// Module: template
module template::comment_page;

use template::game::{Self, Game};
use std::string::{String};
use sui::table::{Self, Table};
use sui::clock::{Clock};

public struct CommentPage has key, store {
    id: UID,
    games: Table<address, Game>,
}

public struct AdminCap has key {
    id: UID,
}

fun init (ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());

    let comment_page = CommentPage {
        id: object::new(ctx),
        games: table::new(ctx),
    };
    transfer::share_object(comment_page);
}

public fun add_game(ctx: &mut TxContext, comment_page: &mut CommentPage, game_name: String, _admin_cap: &AdminCap) {
    let game = game::new(ctx, game_name);
    let game_address = game.get_address_from_game();
    comment_page.games.add(game_address, game);
}

public fun add_comment(ctx: &mut TxContext, comment_page: &mut CommentPage, game: &Game, text: String, score: u64, clock: &Clock) {
    let game_address = game.get_address_from_game();
    let game = comment_page.games.borrow_mut(game_address);
    game::add_comment(ctx, game, text, score, clock);
}