module kamkam::comment;

use std::string::{String};

const ENotOwner: u64 = 1;

public struct Comment has key, store {
    // Describe the property
    id: UID,
    game_id: ID,
    owner: address,  
    score: u64, // The score of the comment 1-5
    text: String, // The text of the comment
}

public fun new(ctx: &mut TxContext, game_id: ID, score: u64, text: String): Comment {
    let owner = ctx.sender();

    Comment {
        id: object::new(ctx),
        game_id,
        owner,
        score,
        text,
    }
}

public fun get_address_from_comment(comment: &Comment): address {
    comment.id.to_address()
}

public fun get_score(comment: &Comment): u64 {
    comment.score
}

public fun get_text(comment: &Comment): String {
    comment.text
}

public fun modify_score(ctx: &mut TxContext, comment: &mut Comment, score: u64) {
    assert!(ctx.sender() == comment.owner, ENotOwner);
    comment.score = score;
}

public fun modify_text(ctx: &mut TxContext, comment: &mut Comment, text: String) {
    assert!(ctx.sender() == comment.owner, ENotOwner);
    comment.text = text;
}