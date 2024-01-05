use core::dict::Felt252DictTrait;
use core::traits::TryInto;
use core::traits::Into;
use array::ArrayTrait;
use option::OptionTrait;
use core::debug::PrintTrait;

#[derive(Drop)]
struct Matrix {
    col_size: u32,
    row_size: u32,
    data: Array<(u32, u32, felt252)>
}

#[derive(Drop)]
struct Vec {
    size: u32,
    data: Array<(u32, felt252)>
}

trait matrixTrait {
    //initialze a one matrix with [[row,id,value]]
    fn init_one(row: u32, col: u32) -> Matrix;
    //initialize with array of array
    fn init_array(row: u32, col: u32, mat_arr: @Array<Array<felt252>>) -> Matrix;
    fn get_size(self: @Matrix) -> (u32, u32);
}
trait vecTrait {
    //initialze a one matrix with [[row,id,value]]
    fn init_one(size: u32) -> Vec;
    //initialize with a vector
    fn init_array(size: u32, vec_arr: @Array<felt252>) -> Vec;
    fn get_size(self: @Vec) -> u32;
}
impl vecPrintImpl of PrintTrait<Vec> {
    fn print(self: Vec) {
        self.size.print();
        let mut i = 0;
        loop {
            if (i >= self.size) {
                break;
            }
            let (index, value) = self.data.at(i);
            let temp_val = *value;
            temp_val.print();
            i += 1;
        }
    }
}
impl matrixTraitImp of matrixTrait {
    fn init_one(row: u32, col: u32) -> Matrix {
        let mut matrix = Matrix { col_size: col, row_size: row, data: ArrayTrait::new() };
        let mut i: u32 = 0;
        loop {
            if (i >= row) {
                break;
            }
            let mut j: u32 = 0;
            loop {
                if (j >= col) { // let value: felt252 = 10;
                    break;
                }
                // i.print();

                // j.print();

                let value: felt252 = 1;
                matrix.data.append((i, j, value));
                j += 1;
            };
            i += 1;
        };
        matrix
    }
    fn init_array(row: u32, col: u32, mat_arr: @Array<Array<felt252>>) -> Matrix {
        let mut matrix = Matrix { col_size: col, row_size: row, data: ArrayTrait::new() };
        assert(row == mat_arr.len(), 'row mismatch');
        assert(row >= 1, 'empty matrix detected');
        assert(col == mat_arr.at(0).len(), 'col mismatch');
        assert(col >= 1, 'col mismatch');

        let mut i: u32 = 0;
        loop {
            if (i >= row) {
                break;
            }
            let mut j: u32 = 0;
            loop {
                if (j >= col) { // let value: felt252 = 10;
                    break;
                }

                let value = mat_arr.at(i).at(j);
                matrix.data.append((i, j, *value));
                j += 1;
            };
            i += 1;
        };
        matrix
    }

    fn get_size(self: @Matrix) -> (u32, u32) {
        (*self.row_size, *self.col_size)
    }
}
impl vecTraitImp of vecTrait {
    fn get_size(self: @Vec) -> u32 {
        *self.size
    }
    fn init_one(size: u32) -> Vec {
        let mut vec = Vec { size: size, data: ArrayTrait::new() };
        let mut i = 0;
        loop {
            if (i >= size) {
                break;
            }
            let value: felt252 = 1;
            vec.data.append((i, value));
            i += 1;
        };
        vec
    }

    fn init_array(size: u32, vec_arr: @Array<felt252>) -> Vec {
        assert(size == vec_arr.len(), 'size mismatch');
        assert(size >= 1, 'empty vector detected');
        let mut vec = Vec { size: size, data: ArrayTrait::new() };

        let mut i = 0;
        loop {
            if (i >= size) {
                break;
            }
            let value: felt252 = *vec_arr.at(i);
            vec.data.append((i, value));
            i += 1;
        };
        vec
    }
}

fn mapper(mat: @Matrix, vec: @Vec) -> Array<(u32, felt252)> {
    let (row_size, col_size) = mat.get_size();
    let vec_size = vec.get_size();
    assert(vec_size == row_size, 'Dimension mismatch');
    let total_length = row_size * col_size;

    assert(total_length == mat.data.len(), 'total len neq matrix len');
    let mut i = 0;
    let mut result = ArrayTrait::new();
    loop {
        if (i >= total_length) {
            break;
        };

        assert(i < total_length, 'index out of bound');
        let (row, col, mat_value) = mat.data.at(i);

        assert(*row < row_size, 'row mismatch');
        assert(*col < col_size && *col < vec_size, 'col mismatch');
        let (vec_index, vec_value) = vec.data.at(*col);
        let value: felt252 = *mat_value * *vec_value;
        let entry = (*row, value);
        result.append(entry);
        i += 1;
    };
    result
}

fn reducer(key: u32, mapper_result: @Array<(u32, felt252)>) -> (u32, felt252) {
    let mut sum = 0;
    let mut i = 0;
    let total_length = mapper_result.len();
    loop {
        if (i >= total_length) {
            break;
        };
        let (row, value) = mapper_result.at(i);
        if (*row == key) {
            sum += *value;
        };
        i += 1;
    };
    (key, sum)
}

fn final_output(size: u32, mapper_result: @Array<(u32, felt252)>) -> Vec {
    // let mut temp_dic: Felt252Dict<felt252> = Default::default();
    let mut temp_vec: Array<felt252> = Default::default();
    let mut i = 0;
    loop {
        if (i >= size) {
            break;
        };
        let (key, sum) = reducer(i, mapper_result);
        assert(key == i, 'order should match');

        let key: felt252 = key.into();
        // temp_dic.insert(key, sum);
        temp_vec.append(sum);
        i += 1;
    };
    //copying value from dict to vect
    vecTrait::init_array(size, @temp_vec)
}
