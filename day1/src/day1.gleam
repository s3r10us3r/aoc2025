import gleam/bool
import gleam/io
import gleam/result
import gleam/int
import gleam/list
import gleam/string
import simplifile

fn get_data() -> List(Int) {
  let data = simplifile.read("data.txt")

  case data {
    Ok(content) -> {
      let splits = string.split(content, on: "\n")
      let splits = list.filter(splits, fn(s) {
        string.is_empty(s) |> bool.negate()
      })
      let num_splits = list.map(splits, fn(s) {
        let clean = string.trim(s)
        let left = string.slice(clean, 0, 1)
        let right = string.drop_start(clean, 1)
        let num = int.parse(right)
        case result.is_ok(num) {
          False -> panic as "Could not read NUM"
          True -> Nil
        }
        let num = result.unwrap(num, 0)

        case left {
          "L" -> -num
          "R" -> num
          _ -> panic as "Invalid left"
        }
      })
      num_splits
    }
    Error(error) -> panic as simplifile.describe_error(error)
  }
}

fn task1() {
  let data = get_data()
  let #(res, _) = list.fold(data, #(0, 50), fn(acc, num) {
    let #(result, dial) = acc
    let dial = num + dial
    let dial = case dial {
      num if num % 100 == 0 -> 0
      num if num > 99 -> num % 100
      num if num < 0 -> num % 100 + 100
      num -> num
    }
    case dial {
      0 -> #(result + 1, dial)
      _ -> #(result, dial)
    }
  })
  io.println(int.to_string(res))
}


fn task2() {
  let data = get_data()
  let #(res, _) = list.fold(data, #(0, 50), fn(acc, num) {
    let #(result, dial) = acc
    let full_spin = int.absolute_value(num) / 100

    let remainder = num % 100
    let raw_pos = dial + remainder

    let cross_point = case raw_pos {
      val if val >= 100 && dial != 0 -> 1
      val if val < 0 && dial != 0 -> 1
      0 -> 1 
      _ -> 0
    }

    let new_dial = case raw_pos % 100 {
      d if d < 0 -> d + 100
      d -> d
    }

    #(result + full_spin + cross_point, new_dial)
  })
  io.println(int.to_string(res))
}

pub fn main() -> Nil {
  task1()
  task2()
}
