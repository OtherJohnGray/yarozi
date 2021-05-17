require 'test'

class TestCompression < Test

  def test_lz4
    mixed_disks do
      result = nil
      task = Task.new
      with_screen 46, 200 do
        # with_dialog :menu, Proc.new{|*args| result = args; "lz4"} do
          q = RootInstaller::Questions::Compression.new(task)
          q.ask
          # assert_instance_of Question::Dialog, q.dialog
          # assert_equal "Root Dataset Compression", q.dialog.title
          # assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
          # assert_nil   q.dialog.ok_label
          # assert_equal fetch_or_save(result.to_s), result.to_s
          # assert_equal "lz4", task.root_compression_type
          # assert q.follow_on_questions.empty?
        # end
      end  
    end  
  end

  # def test_gzip
  #   mixed_disks do
  #     result = nil
  #     task = Task.new
  #     with_screen 46, 200 do
  #       with_dialog :menu, Proc.new{|*args| result = args; "gzip"} do
  #         q = RootInstaller::Questions::Compression.new(task)
  #         q.ask
  #         assert_instance_of Question::Dialog, q.dialog
  #         assert_equal "Root Dataset Compression", q.dialog.title
  #         assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
  #         assert_nil   q.dialog.ok_label
  #         assert_equal fetch_or_save(result.to_s), result.to_s
  #         assert_equal "gzip", task.root_compression_type
  #         assert_equal 1, q.follow_on_questions.length
  #         assert_instance_of RootInstaller::Questions::GzipLevel, q.follow_on_questions.first
  #       end
  #     end  
  #   end  
  # end

  # def test_zstd
  #   mixed_disks do
  #     result = nil
  #     task = Task.new
  #     with_screen 46, 200 do
  #       with_dialog :menu, Proc.new{|*args| result = args; "zstd"} do
  #         q = RootInstaller::Questions::Compression.new(task)
  #         q.ask
  #         assert_instance_of Question::Dialog, q.dialog
  #         assert_equal "Root Dataset Compression", q.dialog.title
  #         assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
  #         assert_nil   q.dialog.ok_label
  #         assert_equal fetch_or_save(result.to_s), result.to_s
  #         assert_equal "zstd", task.root_compression_type
  #         assert_equal 1, q.follow_on_questions.length
  #         assert_instance_of RootInstaller::Questions::ZstdLevel, q.follow_on_questions.first
  #       end
  #     end  
  #   end  
  # end

  # def test_zstd_fast
  #   mixed_disks do
  #     result = nil
  #     task = Task.new
  #     with_screen 46, 200 do
  #       with_dialog :menu, Proc.new{|*args| result = args; "zstd-fast"} do
  #         q = RootInstaller::Questions::Compression.new(task)
  #         q.ask
  #         assert_instance_of Question::Dialog, q.dialog
  #         assert_equal "Root Dataset Compression", q.dialog.title
  #         assert_equal "YAROZI - Yet Another Root On ZFS installer", q.dialog.backtitle
  #         assert_nil   q.dialog.ok_label
  #         assert_equal fetch_or_save(result.to_s), result.to_s
  #         assert_equal "zstd-fast", task.root_compression_type
  #         assert_equal 1, q.follow_on_questions.length
  #         assert_instance_of RootInstaller::Questions::ZstdFastLevel, q.follow_on_questions.first
  #       end
  #     end  
  #   end  
  # end

end
  