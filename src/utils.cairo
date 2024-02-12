mod random;

const MAX_U32: u32 = 2147483647;

// Calculate the distance between two points (x1, y1) and (x2, y2)
// Inputs are u32 type coordinates and a scale factor for improved precision in the sqrt function
fn calculate_distance(x1: u32, y1: u32, x2: u32, y2: u32, scale: u32) -> u32 {
    let mut diff_x: u32 = 0;
    let mut diff_y: u32 = 0;
    if (x1 > x2) {
        diff_x = x1 - x2;
    } else {
        diff_x = x2 - x1;
    }

    if (y1 > y2) {
        diff_y = y1 - y2;
    } else {
        diff_y = y2 - y1;
    }

    return sqrt(diff_x * diff_x + diff_y * diff_y, scale);
}


// Calculates the integer square root of n using Newton's iterative method
// Multiplies and divides by the scale factor to improve precision during integer division
fn sqrt(n: u32, scale: u32) -> u32 {
    if (n == 0) {
        return 0;
    }

    let n_scaled = n * scale * scale;
    let mut x = n_scaled;
    let mut y = 0;

    loop {
        y = (x + n_scaled / x) / 2;
        if y >= x {
            break;
        } else {
            x = y;
        };
    };

    return x / scale;
}

#[cfg(test)]
mod test {
    use super::{sqrt, calculate_distance};

    #[test]
    #[available_gas(3000000000)]
    fn test_calculate_distance() {
        assert(calculate_distance(4, 7, 8, 3, 100) == 5, 'invalid result');

        assert(calculate_distance(1, 1, 1, 1, 100) == 0, 'invalid result');
    }

    #[test]
    #[available_gas(3000000000)]
    fn test_sqrt() {
        let v1 = 10;
        let v2 = 25;
        let v3 = 10000;

        assert(sqrt(v1, 100) == 3, 'invalid result');
        assert(sqrt(v2, 100) == 5, 'invalid result');
        assert(sqrt(v3, 100) == 100, 'invalid result');
    }
}
