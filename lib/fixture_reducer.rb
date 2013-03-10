require "fixture_reducer/version"

module FixtureReducer
  class FixtureReducer
    # also use multiline fixture declarations
    FIXTURE_REX = /(^\s+)fixtures\s+([^,\s]+(,\s*[^,\s]+)*)/m

    attr_reader :test_file

    def initialize(test_file)
      @test_file = test_file
      @test_folder = test_file.split("/").first
      @test_extension = "_#{@test_folder}.rb"
    end

    def reduce_fixtures!
      if fixtures = fixture_params(test_file)
        puts "#{test_file} uses #{fixtures.join(", ")}"

        if run_with(fixtures)
          puts "initial run: SUCCESS"
          original_fixtures = fixtures.dup
          fixtures = reduced_via_common([99, 95, 90, 80, 50]) if fixtures == [":all"]
          fixtures = reduce_one_by_one(fixtures)
          report_and_keep_reduction(original_fixtures, fixtures)
        else
          puts "initial run: FAILED"
        end
      else
        puts "did not find fixtures in #{test_file}"
      end
    end

    private

    def usage_stats
      @usage_stats ||= begin
        used_fixtures = Dir["#{@test_folder}/**/*#{@test_extension}"].map { |file| fixture_params(file) }.compact.flatten
        used_fixtures -= [":all"]
        used_fixtures.flatten.group_by(&:to_s).map { |g, f| [g, f.size] }.sort_by(&:last)
      end.freeze
    end

    def common_fixtures(percent)
      usage = usage_stats.dup
      total = usage.map(&:last).inject(&:+)
      used = 0
      used += usage.shift.last while used < (total / 100 * percent)
      usage.reverse.map(&:first)
    end

    def run(file)
      `bundle exec rake db:test:prepare && #{test_runner} #{file}`
      $?.success?
    end

    def test_runner
      if File.exist? ".zeus.sock"
        "zeus testrb"
      else
        "bundle exec ruby"
      end
    end

    def run_with(fixtures)
      old = read(test_file)
      write_fixtures(fixtures)
      run test_file
    ensure
      write(test_file, old)
    end

    def write(file, content)
      File.open(file, 'w'){|f| f.write content }
    end

    def write_fixtures(fixtures)
      code = (fixtures.empty? ? "" : "fixtures #{fixtures.join(', ')}")
      write(test_file, File.read(test_file).sub(FIXTURE_REX, "\\1#{code}"))
    end

    def read(file)
      File.read(file)
    end

    def fixtures_in_file
      found = fixture_params(test_file)
      found == [":all"] ? available_fixtures : found
    end

    def fixture_params(file)
      content = File.read(file)
      return unless match = content.match(FIXTURE_REX)
      match[2].split(/,\s+/)
    end

    def available_fixtures
      folder = "#{@test_folder}/fixtures/"
      extensions = ["yml", "csv"]
      Dir["#{folder}*.{#{extensions.join(",")}}"].map{|f| f.sub(%r{#{folder}(.*)(\.#{extensions.join("|")})}, ":\\1") }
    end

    def report_and_keep_reduction(original_fixtures, fixtures)
      original_fixtures = available_fixtures if original_fixtures == [":all"]
      removed_fixtures = original_fixtures - fixtures

      if removed_fixtures.empty?
        puts "could not reduce fixtures"
      else
        puts "could reduce fixtures by #{removed_fixtures.size}"
        write_fixtures(fixtures)
      end
    end

    def reduced_via_common(percentages)
      last_success = nil
      percentages.each do |percent|
        fixtures = common_fixtures(percent)
        if run_with(fixtures)
          puts "common #{percent}% run: SUCCESS"
          last_success = fixtures
        else
          puts "common #{percent}% run: FAILED"
          break
        end
      end
      last_success || available_fixtures
    end

    def reduce_one_by_one(fixtures)
      necessary_fixtures = fixtures
      fixtures.each do |fixture|
        current_try = necessary_fixtures - [fixture]

        if read(test_file) =~ /(^|[^a-z\d_])#{fixture.sub(':','')}[\( ]:/
          puts "#{fixture} is called directly"
        elsif run_with(current_try)
          puts "#{fixture} is not needed"
          necessary_fixtures = current_try
        else
          puts "#{fixture} is needed"
        end
      end
      necessary_fixtures
    end
  end
end
