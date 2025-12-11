import gleam/set
import gleam/int
import gleam/dict
import gleam/list
import gleam/string
import gleam/io
import simplifile


fn read_data(path) {
  let assert Ok(content) = simplifile.read(path)
  content 
  |> string.trim()
  |> string.split("\n")
  |> list.fold(dict.new(), fn(racks, line) {
    let assert [name, rest] = string.split(line, ":")
    let outs = rest
    |> string.trim()
    |> string.split(" ")
    dict.insert(racks, name, outs)
  })
}

fn solve1(data) {
  count_paths("you", ["you"], data, "out")
}

fn count_paths(now: String, path: List(String), map: dict.Dict(String, List(String)), goal: String) {
  case now == goal {
    True -> 1
    False -> {
      let assert Ok(outs) = dict.get(map, now)
      list.fold(outs, 0, fn(sum, name) {
        case list.contains(path, name) {
          True -> sum
          False -> sum + count_paths(name, [now, ..path],  map, goal) 
        }
      })
    }
  }
}

fn solve2(data) -> Int {
  let #(svr_fft, _) = count_paths_2("svr", data, "fft", dict.new())
  let #(svr_dac, _) = count_paths_2("svr", data, "dac", dict.new())
  let #(fft_dac, _) = count_paths_2("fft", data, "dac", dict.new())
  let #(dac_fft, _) = count_paths_2("dac", data, "fft", dict.new())
  let #(fft_out, _) = count_paths_2("fft", data, "out", dict.new())
  let #(dac_out, _) = count_paths_2("dac", data, "out", dict.new())
  let svr_ftt_dac_out = svr_fft * fft_dac * dac_out
  let svr_dac_fft_out = svr_dac * dac_fft * fft_out
  svr_ftt_dac_out + svr_dac_fft_out
}

fn count_paths_2(now: String, map: dict.Dict(String, List(String)), goal: String, mem: dict.Dict(String, Int)) -> #(Int, dict.Dict(String, Int)){
  case now == goal {
    True -> #(1, mem)
    False -> {
      case dict.get(mem, now) {
        Ok(v) -> #(v, mem)
        Error(_) -> {
          case dict.get(map, now) {
            Ok(outs) -> {
              let #(res, mem) = list.fold(outs, #(0, mem), fn(dt, name) {
                let #(sum, mem) = dt
                let #(res, mem) = count_paths_2(name, map, goal, mem) 
                #(res + sum, mem)
              })
              #(res, dict.insert(mem, now, res))
            } Error(_) -> #(0, mem)
          }
        }
      }
    }
  }
}

pub fn main() -> Nil {
  let data = read_data("data.txt")
  // solve1(data) |> int.to_string() |> io.println()
  solve2(data) |> int.to_string() |> io.println()
}
