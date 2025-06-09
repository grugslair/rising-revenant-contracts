use crate::world::WorldTrait;
use dojo::model::{Model, ModelStorage};
use dojo::world::WorldStorage;
use starknet::ContractAddress;

#[derive(Drop, Copy, Serde, PartialEq, Introspect)]
enum Role {
    Admin,
    Manager,
    AmmaBlobertAdmin,
    ClassicBlobertAdmin,
    PvpCreator,
    ArcadePaidMinter,
    ArcadeFreeMinter,
    ArcadeMinter,
    ArcadeSetter,
    AchievementSetter,
    Tester,
    CollectionMinter,
}

impl RoleIntoByteArrayImpl of Into<Role, ByteArray> {
    fn into(self: Role) -> ByteArray {
        match self {
            Role::Admin => "admin",
            Role::Manager => "manager",
            Role::AmmaBlobertAdmin => "amma blobert admin",
            Role::ClassicBlobertAdmin => "Blobert admin",
            Role::PvpCreator => "pvp game creator",
            Role::ArcadePaidMinter => "paid minter",
            Role::ArcadeFreeMinter => "free minter",
            Role::ArcadeMinter => "minter",
            Role::ArcadeSetter => "arcade setter",
            Role::AchievementSetter => "achievement setter",
            Role::Tester => "tester",
            Role::CollectionMinter => "collection minter",
        }
    }
}


#[dojo::model]
#[derive(Drop, Serde)]
struct Permission {
    #[key]
    requester: ContractAddress,
    #[key]
    role: Role,
    has: bool,
}

trait PermissionStorage<T> {
    fn get_permissions_storage(self: @T) -> WorldStorage;
    fn get_permission(self: @T, requester: ContractAddress, role: Role) -> bool;
    fn set_permission(ref self: T, requester: ContractAddress, role: Role, has: bool);
    fn set_permissions(ref self: T, permissions: Array<Permission>);
}

/// Implementation of the Permissions trait
///
/// Requires that P can be converted from felt252
impl PermissionImpl<T, +WorldTrait<T>, +Drop<T>> of PermissionStorage<T> {
    fn get_permissions_storage(self: @T) -> WorldStorage {
        self.storage(bytearray_hash!("ba_permissions"))
    }

    fn get_permission(self: @T, requester: ContractAddress, role: Role) -> bool {
        self
            .get_permissions_storage()
            .read_member(Model::<Permission>::ptr_from_keys((requester, role)), selector!("has"))
    }

    fn set_permission(ref self: T, requester: ContractAddress, role: Role, has: bool) {
        let mut storage = self.get_permissions_storage();
        storage.write_model(@Permission { requester, role, has })
    }

    fn set_permissions(ref self: T, permissions: Array<Permission>) {
        let mut array = ArrayTrait::<@Permission>::new();
        for permission in permissions {
            array.append(@permission);
        };
        let mut storage = self.get_permissions_storage();
        storage.write_models(array.span());
    }
}
