use starknet::{ContractAddress, get_block_timestamp};


use crate::world::WorldTrait;
use super::{
    AchievementsEvents, TaskId, ACHIEVEMENTS_NAMESPACE_HASH, components::TrophyCreationInput,
};


#[generate_trait]
impl AchievementImpl<S, +WorldTrait<S>, +Drop<S>> of Achievements<S> {
    fn create_achievements(ref self: S, achievements: Array<TrophyCreationInput>) {
        let mut storage = self.storage(ACHIEVEMENTS_NAMESPACE_HASH);
        for achievement_input in achievements {
            storage.emit_achievement_creation(achievement_input.into());
        };
    }

    fn create_achievement(ref self: S, achievement: TrophyCreationInput) {
        let mut storage = self.storage(ACHIEVEMENTS_NAMESPACE_HASH);
        storage.emit_achievement_creation(achievement.into());
    }

    fn _progress_achievement(
        ref self: S, player_id: ContractAddress, task: TaskId, count: u32, time: u64,
    ) {
        let mut storage = self.storage(ACHIEVEMENTS_NAMESPACE_HASH);
        storage.emit_achievement_progress(player_id.into(), task, count, time);
    }

    fn progress_achievement(
        ref self: S, player_id: ContractAddress, task: TaskId, count: u32, time: u64,
    ) {
        if count > 0 {
            self._progress_achievement(player_id, task, count, time);
        }
    }

    fn progress_achievements(
        ref self: S, player_id: ContractAddress, task_and_counts: Array<(TaskId, u32)>, time: u64,
    ) {
        let mut storage = self.storage(ACHIEVEMENTS_NAMESPACE_HASH);
        let player_felt: felt252 = player_id.into();
        for (task, count) in task_and_counts {
            if count > 0 {
                storage.emit_achievement_progress(player_felt, task, count, time);
            }
        };
    }

    fn progress_achievements_now(
        ref self: S, player_id: ContractAddress, task_and_counts: Array<(TaskId, u32)>,
    ) {
        self.progress_achievements(player_id, task_and_counts, get_block_timestamp());
    }


    fn progress_achievement_now(ref self: S, player_id: ContractAddress, task: TaskId, count: u32) {
        self.progress_achievement(player_id, task, count, get_block_timestamp());
    }

    fn increment_achievement(ref self: S, player_id: ContractAddress, task: TaskId, time: u64) {
        self._progress_achievement(player_id, task, 1, time);
    }

    fn increment_achievement_now(ref self: S, player_id: ContractAddress, task: TaskId) {
        self.increment_achievement(player_id, task, get_block_timestamp());
    }

    fn increment_achievements(
        ref self: S, player_id: ContractAddress, task_and_counts: Array<(TaskId, u32)>, time: u64,
    ) {
        let mut storage = self.storage(ACHIEVEMENTS_NAMESPACE_HASH);
        let player_felt: felt252 = player_id.into();
        for (task, count) in task_and_counts {
            if count > 0 {
                storage.emit_achievement_progress(player_felt, task, count + 1, time);
            }
        };
    }

    fn increment_achievements_now(
        ref self: S, player_id: ContractAddress, task_and_counts: Array<(TaskId, u32)>,
    ) {
        self.increment_achievements(player_id, task_and_counts, get_block_timestamp());
    }
}
