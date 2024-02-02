use core::traits::TryInto;
use core::traits::Into;
use array::ArrayTrait;
use option::OptionTrait;
use core::debug::PrintTrait;
use algorithm::matvectmult::{matrixTrait, vecTrait, mapper, reducer};


#[derive(Destruct, Drop, Copy)]
struct PageRank {
    graph: Array<Array<felt252>>, //src node to dest nodes
    rank: Array<felt252>, //weight of each node
    damping_factor: felt252, //is float allowed???
    max_iterations: felt252,
}

trait PageRankTrait {
    fn init(damping_factor: felt252, max_iterations: felt252) -> PageRank;

    fn add_edge(src: felt252, dest: felt252) -> ();

    fn page_rank(self: @PageRank);
}

impl PageRankTraitImpl of PageRankTrait {
    fn init(damping_factor: felt252, max_iterations: felt252) -> PageRank {
        let graph: Array<Array<felt252>> = Default::default();
        let rank = ArrayTrait::<felt252>::new();
        PageRank {
            graph: graph, rank: rank, damping_factor: damping_factor, max_iterations: max_iterations
        }
    }

    fn add_edge(ref self: PageRank, src: felt252, dest: felt252) -> () {
        self.graph[src][dest] = 1;
    }

    fn page_rank(self:@PageRank){
        //initializing matrix
        let row= self.graph.len();
        let col= self.graph.at(0).len();
        let internal_mat= matrixTrait::init_array(row,col,@self.graph);
        //initializing vector
        let vec_length= self.rank.length();
        let internal_vect= matrixTrait::init_array();
    }
}
