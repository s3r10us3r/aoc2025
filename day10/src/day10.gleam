import gleam/set
import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import gleam/io
import simplifile

type Machine {
  Machine(indicators: set.Set(Int), buttons: List(List(Int)), joltages: List(Int))
}

type Eq {
  Eq(vars: set.Set(Int), sol: Int, size: Int)
}

fn machine_to_eqs(machines: List(Machine)) -> List(List(Eq)) {
  machines
  |> list.map(fn(machine) {
    let indexed_buttons = list.zip(machine.buttons, list.range(0, list.length(machine.buttons) - 1))
    list.index_map(machine.joltages, fn(j, i) {
      let vars = list.fold(indexed_buttons, set.new(), fn(s, i_btn) {
        let #(btn, i_b) = i_btn
        case list.contains(btn, i) {
          True -> set.insert(s, i_b)
          False -> s
        }
      })
      Eq(vars, j, set.size(vars))
    })
  })
}

fn solve2(machines: List(Machine)) {
  machine_to_eqs(machines)
  |> list.map(solve2_helper)
  |> list.fold(0, fn(acc, res) {
    acc + res
  })
}

fn solve2_helper(eqs: List(Eq)) -> Int {
  let sorted_eqs = list.sort(eqs, fn(eq1, eq2) {
    int.compare(eq1.size, eq2.size)
  }) |> list.filter(fn(eq: Eq) { eq.size != 0 })
  case sorted_eqs {
    [] -> 0
    [first, .._] -> {
      let max = first.sol
      let nums = list.range(0, max)
      let assert Ok(var) = list.first(set.to_list(first.vars))
      let assert Ok(res) = list.map(nums, fn(num) {
        case relax_eqs(sorted_eqs, var, num) {
          Error(_) -> 10_000_000
          Ok(#(new_eqs, res)) -> {
            num + res + solve2_helper(new_eqs)
          }
        }
      })
      |> list.max(fn (a, b) { int.compare(b, a) })
      res
    }
  }
}

fn relax_eqs(eqs: List(Eq), id, value) -> Result(#(List(Eq), Int), Nil) {
  let replaced = eqs
  |> simplify()
  |> list.map(fn(eq) {
    replace_w_val(eq, id, value)
  })
  case is_valid(replaced) {
    False -> Error(Nil)
    True -> {
      let filtered: List(Eq) = replaced 
      |> list.filter(fn(eq: Eq) { eq.size != 0 })
      |> list.sort(fn(eq1, eq2) { int.compare(eq1.size, eq2.size) })
      case filtered {
        [] -> Ok(#([], 0))
        [first, .._] -> {
          case first.size == 1 {
            False -> Ok(#(filtered, 0))
            True -> {
              let assert Ok(num) = set.to_list(first.vars) |> list.first()
              let val = first.sol
              case relax_eqs(filtered, num, val) {
                Error(_) -> Error(Nil)
                Ok(#(new_eq, res)) -> Ok(#(new_eq, res + val)) 
              }
            }
          }
        }
      }
    }
  }
}

//eqs must be sorted before
fn simplify(eqs: List(Eq)) {
  case eqs {
    [] -> []
    [first, ..rest] -> {
      let simplified = list.map(rest, fn(eq) {
        case set.is_subset(first.vars, eq.vars) {
          False -> eq
          True -> Eq(set.difference(eq.vars, first.vars), eq.sol - first.sol, eq.size - first.size)
        }
      })
      [first, ..simplify(simplified)]
    }
  }
}

fn is_valid(eqs: List(Eq)) -> Bool {
  case eqs {
    [] -> True
    [first, ..rest] -> {
      case {first.size == 0 && first.sol != 0} || first.sol < 0 {
        True -> False
        False -> is_valid(rest)
      }
    }
  }
}

fn replace_w_val(eq: Eq, id, value) {
  case set.contains(eq.vars, id) {
    False -> eq
    True -> {
      Eq(set.delete(eq.vars, id), eq.sol - value, eq.size - 1)
    }
  }
}

fn new_machine(indicators: String, buttons: List(String), joltages: String) {
  let indicators = indicators
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.to_graphemes()
  |> list.index_fold(set.new(), fn(acc, item, i) {
      case item {
        "#" -> set.insert(acc, i)
        _ -> acc
      }
    })
  let buttons = buttons
  |> list.map(fn(b) {
      b 
      |> string.trim()
      |> string.drop_start(1) 
      |> string.drop_end(1)
      |> string.split(",")
      |> list.map(fn(s) {
        let assert Ok(num) = int.parse(s)
        num
      })
    })
  let joltages = joltages 
  |> string.trim()
  |> string.drop_start(1)
  |> string.drop_end(1)
  |> string.split(",")
  |> list.map(fn(s) {
      let assert Ok(num) = int.parse(s)
      num
    })
  Machine(indicators, buttons, joltages)
}

fn read_data(path: String) -> List(Machine) {
  let assert Ok(content) = simplifile.read(path)
  content
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn (line){
    let parts = line |> string.trim() |> string.split(" ")
    let assert Ok(first) = list.first(parts)
    let assert Ok(last) = list.last(parts)
    let buttons = parts |> list.drop(1) |> list.reverse() |> list.drop(1) |> list.reverse()
    new_machine(first, buttons, last)
  })
}

fn solve1(machines: List(Machine)) -> Int {
  machines 
  |> list.fold(0, fn(sum, machine) {
    let res = solve1_rec(set.new(), machine.buttons, machine.indicators)
    sum + res
  })
}

fn solve1_rec(curr: set.Set(Int), buttons: List(List(Int)), goal: set.Set(Int)) {
  case curr == goal {
    True -> 0
    False -> {
      case buttons {
        [] -> 1_000_000_000
        [btn, ..rest] -> {
          let new_curr = list.fold(btn, curr, fn(state, num) {
            case set.contains(state, num) {
              True -> set.delete(state, num)
              False -> set.insert(state, num)
            }
          })
          int.min(solve1_rec(curr, rest, goal), solve1_rec(new_curr, rest, goal) + 1)
        }
      }
    }
  }
}


pub fn main() -> Nil {
  let machines = read_data("data.txt")
  solve1(machines) |> int.to_string() |> io.println()
  solve2(machines) |> int.to_string() |> io.println()
}
