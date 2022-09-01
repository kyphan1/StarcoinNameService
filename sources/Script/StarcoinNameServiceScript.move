module SNSadmin::StarcoinNameServiceScript{
    use StarcoinFramework::Option;
    use StarcoinFramework::Vector;
    // use StarcoinFramework::NFT;
    // use StarcoinFramework::IdentifierNFT;
    // use StarcoinFramework::NFTGallery;
    // use StarcoinFramework::Signer;

    use SNSadmin::StarcoinNameService as SNS;
    use SNSadmin::DomainNameASCII as DomainName;
    use SNSadmin::Root;
    use SNSadmin::Registrar;
    use SNSadmin::Resolver;
    // use SNSadmin::NameServiceNFT::{SNSMetaData, SNSBody};

    struct DomainInfo has copy,drop{
        registryDetails : Registrar::RegistryDetails,
        stc_address   : address 
    }

    //TODO : add <ROOT:store>
    public (script) fun register(sender:signer, name: vector<u8>,registration_duration: u64){
        let name_split = DomainName::get_dot_split(&name);
        let name_split_length = Vector::length(&name_split);
        assert!(name_split_length == 2, 100 );
        if( b"stc" == *Vector::borrow(&name_split, 1)){
            SNS::register<Root::STC>(&sender, Vector::borrow(&name_split, 0), Vector::borrow(&name_split, 1), registration_duration);
        }else{
            abort 102333
        }
    }

    // public (script) fun use_with_config (sender:signer, id: u64, stc_address: address){
    //     SNS::use_domain(&sender,id,stc_address);
    // }

    public (script) fun use_domain<ROOT: store>(sender:signer, id: u64){
        SNS::use_domain<ROOT>(&sender, id);
    }

    public (script) fun unuse_domain<ROOT: store>(sender:signer){
        SNS::unuse_domain<ROOT>(&sender);
    }

    public (script)fun change_stc_address<ROOT: store>(sender:signer,addr:address){
        SNS::change_stc_address<ROOT>(&sender,Option::none<u64>(),addr);
    }

    public (script)fun change_NFTGallery_stc_address<ROOT: store>(sender:signer,id:u64,addr:address){
        SNS::change_stc_address<ROOT>(&sender,Option::some(id),addr);
    }

    // public (script)fun add_Record_address(sender:signer,name:vector<u8>,addr:vector<u8>){
    //     SNS::change_Record_address(&sender,Option::none<u64>(),&name,&addr);
    // }

    // public (script)fun change_NFTGallery_Record_address(sender:signer,id:u64,name:vector<u8>,addr:vector<u8>){
    //     SNS::change_Record_address(&sender,Option::some(id),&name,&addr);
    // }
    
    public fun resolve_domain_name<ROOT: store>(addr:address):vector<u8>{
        SNS::resolve_domain_name<ROOT>(addr)
    }

    public fun resolve_4_name<ROOT: store>(name:vector<u8>):address{
        SNS::resolve_stc_address<ROOT>(&DomainName::get_domain_name_hash(&name))
    }

    public fun resolve_4_node<ROOT: store>(node:vector<u8>):address{
        SNS::resolve_stc_address<ROOT>(&node)
    }

    public fun get_domain_expiration_time<ROOT: store>(name:vector<u8>):u64{
        let name_split = DomainName::get_dot_split(&name);
        let name_split_length = Vector::length(&name_split);
        assert!(name_split_length == 2, 100 );
        let name_hash = DomainName::get_domain_name_hash(&name);
        let op_registryDetails = Registrar::get_details_by_hash<ROOT>(&name_hash);
        if(Option::is_some(&op_registryDetails)){
            Registrar::get_expiration_time(Option::borrow(&op_registryDetails))
        }else{
            0
        }
    }

    public fun get_domain_info<ROOT: store>(name:vector<u8>):Option::Option<DomainInfo>{
        let name_split = DomainName::get_dot_split(&name);
        let name_split_length = Vector::length(&name_split);
        assert!(name_split_length == 2, 100 );
        if( b"stc" == *Vector::borrow(&name_split, 1)){
            let name_hash = DomainName::get_name_hash_2(Vector::borrow(&name_split, 1), Vector::borrow(&name_split, 0));
            let op_registryDetails = Registrar::get_details_by_hash<ROOT>(&name_hash);
            let registryDetails = if(Option::is_some(&op_registryDetails)){
                Option::destroy_some(op_registryDetails)
            }else{
                return Option::none<DomainInfo>()
            };
            let op_stc_address = Resolver::get_address_by_hash<ROOT>(&name_hash);
            let stc_address = if(Option::is_some(&op_stc_address)){
                Option::destroy_some(op_stc_address)
            }else{
                return Option::none<DomainInfo>()
            };
            return Option::some(DomainInfo{registryDetails,
                                stc_address
                                })
        }else{
            abort 102333
        }
    }

    
    #[test]
    fun test_split_name (){
        let name = b"iamtimhhh.stc";
        StarcoinFramework::Debug::print(&SNSadmin::DomainNameASCII::get_dot_split(&name))
    }
    // public fun get_all_domain_info<ROOT: store>(addr: address):vector<NFT::NFTInfo<SNSMetaData<ROOT>>>{
    //     let res = NFTGallery::get_nft_infos<SNSMetaData<ROOT>,SNSBody>(addr);
    //     let op_info = IdentifierNFT::get_nft_info<SNSMetaData<ROOT>,SNSBody>(addr);
    //     if(Option::is_some(&op_info)){
    //         Vector::push_back(&mut res, Option::destroy_some(op_info));
    //     };
    //     res
    // }


    // public fun resolve_record_address_4_name(domain:vector<u8>,name:vector<u8>):vector<u8>{
    //     SNS::resolve_record_address(&DomainName::get_name_hash_2(&b"stc",&domain),&b"stc",&name)
    // }

    // public fun resolve_record_address_4_node(node:vector<u8>,name:vector<u8>):vector<u8>{
    //     SNS::resolve_record_address(&node,&b"stc",&name)
    // }

}