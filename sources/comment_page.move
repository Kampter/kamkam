module kamkam::comment_page;

use kamkam::game::{Self, Game};
use std::string::{String};
use sui::package;
use sui::display;
use sui::table::{Self, Table};

const COMMENT_PAGE_SITE: address = @0x1;
const EALREADY_EXISTS:u64 = 0;

public struct CommentPage has key, store {
    id: UID,
    games: Table<address, Game>, 
}

public struct COMMENT_PAGE has drop {}

fun init (otw: COMMENT_PAGE, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    let mut site_display = display::new<CommentPage>(&publisher, ctx);
 
    let comment_page = CommentPage {
        id: object::new(ctx),
        games: table::new(ctx),
    }; 

    site_display.add(b"link".to_string(), b"http://{b36string}.walrus.site".to_string());
    site_display.add(b"walrus site address".to_string(), COMMENT_PAGE_SITE.to_string());
    site_display.update_version(); 
 
    transfer::public_share_object(comment_page);
    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(site_display, ctx.sender());
}

public fun add_game(ctx: &mut TxContext, comment_page: &mut CommentPage, game_name: String, blob_id: String) {
    let game = game::new(ctx, blob_id, game_name);
    let game_address = game.get_address_from_game();
    assert!(!comment_page.games.contains(game_address), EALREADY_EXISTS);
    comment_page.games.add(game_address, game);
}

public fun add_comment(ctx: &mut TxContext, comment_page: &mut CommentPage, game: &Game, text: String, score: u64) {
    let game_address = game.get_address_from_game();
    let game = comment_page.games.borrow_mut(game_address);
    game::add_comment(ctx, game, text, score);
}