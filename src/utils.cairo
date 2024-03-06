mod random;
mod vrgda;
use starknet::{get_block_info};
use risingrevenant::components::outpost::Position;

const SQRT_SCALE: u32 = 1000;

// Calculate the distance between two points (x1, y1) and (x2, y2)
// Inputs are u32 type coordinates and a scale factor for improved precision in the sqrt function

fn calculate_distance(position1: Position, position2: Position) -> u32 {
    let mut diff_x: i64 = position1.x.into() - position2.x.into();
    let mut diff_y: i64 = position1.y.into() - position2.y.into();

    return sqrt::<u64>((diff_x * diff_x + diff_y * diff_y).try_into().unwrap()).try_into().unwrap();
}

// Calculates the integer square root of n using Newton's iterative method
// Multiplies and divides by the scale factor to improve precision during integer division
fn sqrt<
    T, +Into<u32, T>, +PartialEq<T>, +PartialOrd<T>, +Mul<T>, +Div<T>, +Add<T>, +Drop<T>, +Copy<T>
>(
    n: T
) -> T {
    let zero: T = 0_u32.into();
    let two: T = 2_u32.into();
    let scale: T = SQRT_SCALE.into();

    if (n == zero) {
        return zero;
    }

    let n_scaled = n * scale * scale;
    let mut x = n_scaled;
    let mut y = zero;

    loop {
        y = (x + n_scaled / x) / two;
        if y >= x {
            break;
        } else {
            x = y;
        };
    };

    return x / scale;
}


fn get_block_number() -> u64 {
    get_block_info().unbox().block_number
}
