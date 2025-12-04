import gleam/int
import gleam/list
import gleam/string
import simplifile
import gleam/io

fn get_data() -> List(List(Int)) {
  let assert Ok(content) = simplifile.read("data.txt")
  let clean_content = string.trim(content)
  let splits = string.split(clean_content, ",")
  list.map(splits, fn(text_range) {
    string.split(text_range, "-") |> list.map(fn(s) {
      let assert Ok(num) = int.parse(s)
      num
    })
  })
}

fn task1() {
  let data = get_data()
  let res = list.fold(data, 0, fn(acc, range) {
    let assert [s, max] = range
    acc + task1_helper(s, max)
  })
  io.println(int.to_string(res))
}

fn task1_helper(num, max) -> Int {
  case num > max {
    True -> 0
    False -> {
      let s = int.to_string(num)
      case string.length(s) {
        l if l % 2 != 0 -> task1_helper(num + 1, max)
        l -> {
          let left = string.slice(s, 0, l / 2)
          let right = string.slice(s, l / 2, l / 2)
          case left == right {
            True -> task1_helper(num + 1, max) + num
            False -> task1_helper(num + 1, max)
          }
        }
      }
    }
  }
}

fn task2() {
  let data = get_data()
  let res = list.fold(data, 0, fn(acc, range) {
    let assert [s, max] = range
    acc + task2_helper(s, max)
  })
  io.println(int.to_string(res))
}

fn task2_helper(num, max) -> Int {
  case num > max {
    True -> 0
    False -> {
      let s = int.to_string(num)
      case is_pattern(s, 1) {
        True -> {
          num + task2_helper(num + 1, max)
        }
        False -> task2_helper(num + 1, max)
      }
    }
  }
}

fn is_pattern(s, l) -> Bool {
  let str_len = string.length(s)
  let pattern = string.slice(s, 0, l)
  case str_len % l {
    0 if l != str_len -> {
      case break_to_substrings(s, l)
        |> list.all(fn(sub) {
        sub == pattern
      }) {
        True -> True
        False -> is_pattern(s, l + 1)
      }
    }
    _ if l <= str_len / 2 -> is_pattern(s, l + 1)
    _ -> False
  }
}

fn break_to_substrings(s, l) -> List(String) {
  s 
    |> string.to_graphemes()
    |> list.sized_chunk(l)
    |> list.map(string.concat)
}

pub fn main() -> Nil {
  task1()
  task2()
}
