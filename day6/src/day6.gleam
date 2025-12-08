import gleam/set
import gleam/int
import gleam/list
import gleam/string
import simplifile
import gleam/io

fn read_data_1() {
  let assert Ok(content) = simplifile.read("data.txt")
  let lines = content 
    |> string.trim
    |> string.split("\n")
  let assert Ok(last_line) = list.last(lines)
  let signs = last_line |> strip_all_spaces() |> string.split(" ")
  let nums = lines
    |> list.reverse()
    |> list.drop(1)
    |> list.reverse()
    |> list.map(fn (s) {
      s
        |> strip_all_spaces()
        |> string.trim()
        |> string.split(" ")
        |> list.map(fn (s) {
          let assert Ok(num) = int.parse(s)
          num
        })
    })
  #(nums, signs)
}

fn read_data_2() {
  let assert Ok(content) = simplifile.read("data.txt")
  let lines = content
    |> string.trim()
    |> string.split("\n")
  let assert Ok(last_line) = list.last(lines)
  let lines = lines 
    |> list.reverse()
    |> list.drop(1)
    |> list.reverse()
  #(lines, last_line)
}

fn task2() {
  3
} 

fn strip_all_spaces(s) -> String {
  case string.replace(s, "  ", " ") {
    val if s == val -> s
    val -> strip_all_spaces(val)
  }
}

fn task1() {
  let #(nums, signs) = read_data_1()
  let ls = list.repeat([], list.length(signs))
  list.fold(nums, ls, fn(ls, nums) {
    zip2(ls, nums)
  }) 
  |> list.zip(signs)
  |> list.map(fn(tup) {
    let #(nums, sign) = tup
    case sign {
      "*" -> #(nums, sign, 1)
      "+" -> #(nums, sign, 0)
      _ -> panic as {"invalid sign" <> sign}
    }
  })
  |> list.map(fn(tup) {
    let #(nums, sign, s) = tup
    list.fold(nums, s, fn(num, s) {
      case sign {
        "*" -> s * num
        "+" -> s + num
        _ -> panic as {"invalid sign" <> sign}
      }
    })
  })
  |> list.fold(0, int.add)
} 

fn zip2(l1, l2) {
  list.zip(l1, l2) 
    |> list.map(fn (tup) {
      let #(l, n) = tup
      [n, ..l]
  })
}

pub fn main() -> Nil {
  let t1 = task1()
  io.println(int.to_string(t1))
}
