use starknet::ContractAddress;
use dojo::{world::WorldStorage, event::EventStorage};
use achievement::types::task::Task;
use achievement::events::creation::TrophyCreation;
use achievement::events::progress::TrophyProgression;

const ACHIEVEMENTS_NAMESPACE_HASH: felt252 = bytearray_hash!("achievements");

#[derive(Drop, Serde, Copy, PartialEq)]
enum TaskId {}


impl TaskIdIntoFelt252 of Into<TaskId, felt252> {
    fn into(self: TaskId) -> felt252 {
        match self {}
    }
}

#[derive(Drop, Serde)]
struct TaskInput {
    id: TaskId,
    total: u32,
    description: ByteArray,
}

#[derive(Drop, Serde)]
struct TrophyCreationInput {
    id: felt252,
    hidden: bool,
    index: u8,
    points: u16,
    start: u64,
    end: u64,
    group: felt252,
    icon: felt252,
    title: felt252,
    description: ByteArray,
    tasks: Array<TaskInput>,
    data: ByteArray,
}


impl TaskInputIntoTask of Into<TaskInput, Task> {
    fn into(self: TaskInput) -> Task {
        Task { id: self.id.into(), total: self.total, description: self.description }
    }
}

impl CreationInputIntoTrophyCreation of Into<TrophyCreationInput, TrophyCreation> {
    fn into(self: TrophyCreationInput) -> TrophyCreation {
        let mut tasks = ArrayTrait::<Task>::new();
        for task in self.tasks {
            tasks.append(task.into());
        };
        TrophyCreation {
            id: self.id,
            hidden: self.hidden,
            index: self.index,
            points: self.points,
            start: self.start,
            end: self.end,
            group: self.group,
            icon: self.icon,
            title: self.title,
            description: self.description,
            tasks: tasks.span(),
            data: self.data,
        }
    }
}

#[generate_trait]
impl AchievementsEventsImpl of AchievementsEvents {
    fn emit_achievement_creation(ref self: WorldStorage, trophy: TrophyCreation) {
        self.emit_event(@trophy);
    }
    fn emit_achievement_progress(
        ref self: WorldStorage, player_id: felt252, task: TaskId, count: u32, time: u64,
    ) {
        self
            .emit_event(
                @TrophyProgression { player_id: player_id, task_id: task.into(), count, time },
            );
    }
}
