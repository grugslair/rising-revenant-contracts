use starknet::{get_caller_address};
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct PermissionsModel {
    #[key]
    namespace: felt252,
    #[key]
    resource: felt252,
    #[key]
    requester: felt252,
    permissions: felt252,
}


trait Permissions<R, S, P> {
    fn get_permissions(self: @IWorldDispatcher, namespace: felt252, resource: R, requester: S) -> P;
    fn set_permissions(
        self: IWorldDispatcher, namespace: felt252, resource: R, requester: S, permissions: P
    );
}

impl Felt252PermissionsImpl<
    R, S, +Into<R, felt252>, +Into<S, felt252>, +Drop<R>, +Drop<S>
> of Permissions<R, S, felt252> {
    fn get_permissions(
        self: @IWorldDispatcher, namespace: felt252, resource: R, requester: S
    ) -> felt252 {
        let (resource, requester): felt252 = resource.into();
        // let permissions_entity: PermissionsModel = self
        //     .get_from_id(resource.into(), requester.into());
        // let permissions: PermissionsModel = self.get(resource.into(), requester.into());
        // permissions.permissions
        // PermissionsModelEntityStore::get(
        //     *self,
        // )
        //     .permissions

        // PermissionsModelStore::get_permissions(
        //     *self, resource.into(), requester.into()
        // )
        12
    }
    fn set_permissions(
        self: IWorldDispatcher, namespace: felt252, resource: R, requester: S, permissions: felt252
    ) {
        self.get_permissions(resource, get_caller_address());
        PermissionsModel {
            resource: resource.into(), requester: requester.into(), permissions: permissions
        }
            .set(self);
    }
}
impl BoolPermissionsImpl<
    R, S, +Into<R, felt252>, +Into<S, felt252>, +Drop<R>, +Drop<S>
> of Permissions<R, S, bool> {
    fn get_permissions(
        self: @IWorldDispatcher, namespace: felt252, resource: R, requester: S
    ) -> bool {
        Felt252PermissionsImpl::get_permissions(self, namespace, resource, requester) != 0_felt252
    }
    fn set_permissions(
        self: IWorldDispatcher, namespace: felt252, resource: R, requester: S, permissions: bool
    ) {
        Felt252PermissionsImpl::set_permissions(
            self, resource, requester, if permissions {
                1_felt252
            } else {
                0_felt252
            }
        );
    }
}

impl OtherPermissionsImpl<
    R,
    S,
    P,
    +Into<R, felt252>,
    +Into<S, felt252>,
    +Into<P, felt252>,
    +TryInto<felt252, P>,
    +Drop<R>,
    +Drop<S>,
    +Drop<P>
> of Permissions<R, S, P> {
    fn get_permissions(self: @IWorldDispatcher, namespace: N, resource: R, requester: S) -> P {
        Felt252PermissionsImpl::get_permissions(self, namespace, resource, requester)
            .try_into()
            .unwrap()
    }
    fn set_permissions(
        self: IWorldDispatcher, namespace: N, resource: R, requester: S, permissions: P
    ) {
        Felt252PermissionsImpl::set_permissions(
            self, namespace, resource, requester, permissions.into()
        );
    }
}

