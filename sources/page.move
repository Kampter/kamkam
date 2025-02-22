module kamkam::page;

use std::string::{String};
use sui::package;
use sui::display;
use sui::event::{emit};
use kamkam::utils::{to_b36};
use kamkam::comment::{Self};

const COMMENT_PAGE_SITE: address = @0x1;
const EALREADY_EXISTS: u64 = 0;
const EALREADY_COMMENTED:u64 = 1;

public struct Page has key, store {
    id: UID,
    games: vector<address>,
}

public struct PAGE has drop {}

public struct Game has key, store {
    id: UID,
    name: String,
    total_score: u64, // The total score of the game
    num_comments: u64, // The number of comments of the game
    average_score: u64, // The average score of the game
    comments: vector<address>, // The comments of the game
    blobs: vector<String>, 
    b36string: vector<address>,
}

public struct EGameAdded has copy, drop {
    id: ID,
    name: String,
    b36string: String,
}

fun init (otw: PAGE, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    let mut site_display = display::new<Page>(&publisher, ctx);
 
    let page = Page {
        id: object::new(ctx),
        games: vector::empty(),
    }; 

    site_display.add(b"walrus site address".to_string(), COMMENT_PAGE_SITE.to_string());
    site_display.add(b"link".to_string(), b"http://{b36string}.walrus.site".to_string());
    site_display.update_version();
 
    transfer::public_share_object(page);
    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(site_display, ctx.sender());
}

public entry fun add_game(page: &mut Page, name: String, ctx: &mut TxContext, ) {
    let sender = ctx.sender();
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
        blobs: vector::empty(),
        b36string: vector::empty(),
    };
    assert!(!page.games.contains(&object_address), EALREADY_EXISTS);
    vector::push_back(&mut page.games,object_address);
    transfer::transfer(game, sender);   
    
    emit(EGameAdded{
        id: event_id,
        name: name,
        b36string: b36string
    });  
}

#[allow(lint(self_transfer))]
public entry fun add_comment(game: &mut Game, text: String, score: u64, ctx: &mut TxContext) {
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