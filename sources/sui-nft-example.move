/**
 * Simple NFT Contract
 */
module nft::nft_example {
    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// A NFT that can be minted by anybody
    struct NFTExample has key, store {
        id: UID,
        /// Name for the token
        name: string::String,
        /// Description of the token
        description: string::String,
        /// URL for the token
        url: Url,
    }

    /// Mint Event 
    struct MintNFTEvent has copy, drop {
        // The Object ID of the NFT
        object_id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: string::String,
    }

    /// Transfer Evnet
    struct TransfertNFTEvent has copy, drop {
        // The Object ID of the NFT
        object_id: ID,
        // from address
        from: address,
        // to address
        to: address,
    }

    /// Create a new nft_example
    public entry fun mint(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        ctx: &mut TxContext
    ) {
        // create NFTExample Object
        let nft = NFTExample {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url)
        };
        // get sender info
        let sender = tx_context::sender(ctx);
        // emit event
        event::emit(MintNFTEvent {
            object_id: object::uid_to_inner(&nft.id),
            creator: sender,
            name: nft.name,
        });
        // transfer nft to sender
        transfer::public_transfer(nft, sender);
    }

    /// transfer method
    public entry fun transfer(
        nft: NFTExample, 
        recipient: address, 
        _: &mut TxContext
    ) {
        // transfer NFT Object
        transfer::public_transfer(nft, recipient)
    }

    /// Update the `description` of `nft` to `new_description`
    public entry fun update_description(
        nft: &mut NFTExample,
        new_description: vector<u8>,
    ) {
        nft.description = string::utf8(new_description)
    }

    /// Permanently delete `nft`
    public entry fun burn(nft: NFTExample) {
        let NFTExample { id, name: _, description: _, url: _ } = nft;
        // delete NFT
        object::delete(id)
    }

    /// Get the NFT's `name`
    public fun name(nft: &NFTExample): &string::String {
        &nft.name
    }

    /// Get the NFT's `description`
    public fun description(nft: &NFTExample): &string::String {
        &nft.description
    }

    /// Get the NFT's `url`
    public fun url(nft: &NFTExample): &Url {
        &nft.url
    }
}
