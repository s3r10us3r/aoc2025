import gleam/int
import gleam/list
import gleam/string
import simplifile
import gleam/io

fn read_data() -> List(List(Int)) {
  let assert Ok(content) = simplifile.read("data.txt")
  let content = string.trim(content)
  string.split(content, "\n")
    |> list.map(fn(line) {
    line
      |> string.to_graphemes
      |> list.map(fn(s) {
      let assert Ok(i) = int.parse(s)
      i
    })
  })
}

fn task1() {
  let res = read_data()
    |> list.fold(0, fn(sum, battery) {
    let len = list.length(battery)
    let #(left, right, _) = list.index_fold(battery, #(0, 0, len), fn(acc, joltage, index) {
      let #(left, right, len) = acc
      case index == len - 1 {
        True if joltage > right -> #(left, joltage, len)
        True -> #(left, right, len)
        False if joltage > left -> #(joltage, 0, len)
        False if joltage > right -> #(left, joltage, len)
        False -> #(left, right, len)
      }
    })
    sum + left * 10 + right
  })
  io.println(int.to_string(res))
}

fn task2() {
  let res = read_data()
    |> list.fold(0, fn(sum, battery) {
    let len = list.length(battery)
    let res = list.index_fold(battery, list.repeat(0, 12), fn(vals, joltage, index) {
        list.append(list.take(vals, int.max(0, index - len + 12)), find_max(list.drop(vals, int.max(0, index - len + 12)), joltage))
    })
      |> list.fold(0, fn(acc, val) {
        acc * 10 + val
      })
    res + sum
  })
  io.println(int.to_string(res))
}

fn find_max(vals, joltage) -> List(Int) {
  let first_res = list.first(vals)
  case first_res {
    Ok(first) -> {
      case first < joltage {
        True -> [joltage, ..list.repeat(0, list.length(vals) - 1)]
        False -> [first, ..find_max(list.drop(vals, 1), joltage)]
      }
    }
    _ -> vals
  }
}

pub fn main() -> Nil {
  task1()
  task2()
}
