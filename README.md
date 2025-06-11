# シフト希望提出アプリ
このアプリケーションは、アルバイト等のシフト希望を提出するアプリケーションです


## デモ版のURL
https://shifttabledemoapp.site/
※ユーザ名を空欄、パスワードを0000で入れます


## 開発背景
作成した経緯としては、1年生の頃から働かせていただいているアルバイト先が店舗にある名簿にシフト希望を記入しなければならず、不便だと感じ、店舗にいかなくても提出できるシステムを作りたいと考えたことです。  
店長に作った旨をお話しし、実際に今も使っていただいております。  
このアプリの導入により、特に実家が地方にある方や久しぶりに出勤する人達に大変好評で使っていただいております。加えて、シフト希望数も増加し、以前に比べ、人が足りていないときに発生する募集枠がなくなりました。


## 技術選定
主にRuby on Railsを使用し、  
UI調整のためにBootstrapを一部、使用しました。  
デプロイにはAWSを使用しました。  

## 選定意図

### Ruby on Rails
- MVC構造により、アプリの動作が開発初心者の私でも分かりやすく整理されている
- CRUD操作の自動生成機能が充実している  
- ルーティング、バリデーション、フォーム周りの支援機能が豊富  
- 安定した動作で、効率的にWebアプリを作成できる
### Bootstrap
- 統一感のあるデザインを簡単に実現できる  
- Ruby on Railsとの親和性が高く、導入・カスタマイズが容易
### AWS
- 多機能なサービスを一括で利用可能  
- 小規模から大規模へのスケールアップに柔軟に対応できる 


## 主要なソースコード

### ルーティング（`routes.rb`）
<details>
<summary>コード</summary>

```ruby
Rails.application.routes.draw do

  get "manager" => 'homes#top'  #店長用ログインページ
  devise_for :users
  devise_scope :user do
    root "devise/sessions#new"
  end

  resources :users, only: [:index, :show, :edit, :update, :destroy] #従業員
  resources :days, only: [:index, :show, :create, :destroy, :update] do #シフトを提出する日（月～金の一週間ごと）
    get "excel" => 'excel#export' #excelファイル出力
    resources :jobs, only: [:new, :create, :update, :destroy, :edit] do #シフト希望
      resources :job_comments, only: [:create, :destroy, :edit, :update]  #シフト希望の備考
    end
  end
  get "past" => 'days#index2' #過去のシフト

end
```
</details>

### データベース（`schema.rb`）
<details>
<summary>コード</summary>

```ruby
ActiveRecord::Schema.define(version: 2024_11_22_103513) do

  create_table "days", force: :cascade do |t| #シフトを提出する日（月～金の一週間ごと）
    t.date "start", null: false #一週間の開始日（月曜）
    t.date "finish", null: false #一週間の終了日（日曜）
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "limityan", default: false  #シフトの作成済を判別
  end

  create_table "events", force: :cascade do |t| #催事等を記入するため
    t.string "time1", default: "" #月曜日
    t.string "time2", default: "" #火曜日
    t.string "time3", default: "" #水曜日
    t.string "time4", default: "" #木曜日
    t.string "time5", default: "" #金曜日
    t.string "time6", default: "" #土曜日
    t.string "time7", default: "" #日曜日
    t.integer "day_id"  #提出する週
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "fris", force: :cascade do |t| #祝日判定用
    t.integer "day_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "job_comments", force: :cascade do |t| #備考
    t.text "comment"
    t.integer "user_id" #提出するユーザ
    t.integer "job_id"  #提出するシフト
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "day_id"  #提出する週
  end

  create_table "jobs", force: :cascade do |t| #シフト希望
    t.string "time1", default: "" #月曜日
    t.string "time2", default: "" #火曜日
    t.string "time3", default: "" #水曜日
    t.string "time4", default: "" #木曜日
    t.string "time5", default: "" #金曜日
    t.string "time6", default: "" #土曜日
    t.string "time7", default: "" #日曜日
    t.integer "user_id" #提出するユーザ
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "day_id"  #提出する週
  end

  create_table "mons", force: :cascade do |t| #祝日判定用
    t.integer "day_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sats", force: :cascade do |t| #祝日判定用
    t.integer "day_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "thus", force: :cascade do |t| #祝日判定用
    t.integer "day_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tues", force: :cascade do |t| #祝日判定用
    t.integer "day_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|  #従業員
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weds", force: :cascade do |t| #祝日判定用
    t.integer "day_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
```
※曜日に関するテーブル（mons, satsなど）は祝日かどうかを判定するためだけに作成したテーブルです  
　今後、改良する際には、祝日の判定にgemを取り入れ、これらのテーブルの削除したいと考えています。
</details>

### コントローラ（`jobs_controller.rb`）
※シフト希望を提出するコントローラ
<details>
<summary>コード</summary>

```ruby
class JobsController < ApplicationController

  def new
    @job = Job.new
    @day = Day.find(params[:day_id])  #提出するDayモデル（週）を取得
    @user = User.all
    @job_comment = JobComment.where(day_id: @day.id)
    end
  end

  def create
    job = Job.new(job_params)
    day = Day.find(params[:day_id])
    job.day_id = day.id
    job.user_id = current_user.id
    job.save
    flash[:green_message] = "提出しました。"
    redirect_to request.referer
  end


  private
  def job_params
    params.require(:job).permit(:time1,:time2,:time3,:time4,:time5,:time6,:time7)
  end

end
```

### モデル（`job.rb`）
```ruby
class Job < ApplicationRecord

  belongs_to :user  #User（従業員）とJob（シフト希望）は1:N
  belongs_to :day  #Day（各週）とJob（シフト希望）は1:N

end
```
</details>

### ビュー（`jobs/new.html.erb`）
※シフト希望の一覧画面
<details>
<summary>コード</summary>

```erb
<% unless current_user.job_by?(current_user.id, @day.id) %>
  <hr>
  <h3>シフト希望提出</h3>  
    <%= render "form", day:@day %>
  <% end %>
<% end %>
<hr>
<tbody>
<% @user.each_with_index do |user, i| %>
  <tr>
    <td class="one">
      <%= i %>
    </td>
    <td class="name">
      <%= render "jobs/name", user: user %>
    </td>
    <% if user.job_by?(user.id,@day.id) %>
      <% user.jobs.where(day_id: @day.id).each do |job| %>
        <td class="job"><%= job.time1 %></td>
        <td class="job"><%= job.time2 %></td>
        <td class="job"><%= job.time3 %></td>
        <td class="job"><%= job.time4 %></td>
        <td class="job"><%= job.time5 %></td>
        <td class="job"><%= job.time6 %></td>
        <td class="job"><%= job.time7 %></td>
        <% if job.user.id == current_user.id %>
          <td>
            <%= link_to edit_day_job_path(@day.id,job.id) do %>
              <button type="button" class="btn btn-sm btn-outline-primary">
                <i class="fa-solid fa-pen"></i>
              </button>
            <% end %>
            <%= link_to day_job_path(@day.id,job.id), method: :delete do %>
              <button type="button" class="btn btn-sm btn-outline-danger ">
                <i class="fa-solid fa-trash-can"></i>
              </button>
            <% end %>
          </td>
        <% else %>
          <td></td>
        <% end %>
      <% end %>
    <% else %>
      <%= render "blank" %>
    <% end %>
  </tr>
<% end %>
</tbody>
```
</details>

### ビュー（`jobs/_form.html.erb`）
※シフト希望の提出画面
<details>
<summary>コード</summary>

```erb
<%= form_with model:[day, Job.new], url: day_jobs_path(day.id), method: :post do |f| %>
  <div class= "scroll">
    <table class = "table table-sm table-bordered table-hover" >
      <tr class="table-secondary">
        <%= render "day", day:day %>
        <th class="come"></th>
      </tr>
      <tr class="table-secondary">
        <%= render "week", day:day %>
      </tr>
      <tbody>
        <tr>
          <td class="one"></td>
          <td class="name">
            <%= render "jobs/name", user: current_user %>
          </td>
          <td><%= f.text_area :time1 ,class: 'form-control', rows: "2" %></td>
          <td><%= f.text_area :time2 ,class: 'form-control', rows: "2" %></td>
          <td><%= f.text_area :time3 ,class: 'form-control', rows: "2" %></td>
          <td><%= f.text_area :time4 ,class: "form-control", rows: "2" %></td>
          <td><%= f.text_area :time5 ,class: 'form-control', rows: "2" %></td>
          <td><%= f.text_area :time6 ,class: "form-control", rows: "2" %></td>
          <td><%= f.text_area :time7 ,class: 'form-control', rows: "2" %></td>
          <td class="text-left">
            <button type="submit" class="btn btn-primary btn-sm ">提出</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
<% end %>
```
</details>


## 特に力を入れて作成した機能

### Excel形式に出力（`excel_controller.rb`）
<details>
<summary>コード</summary>

```ruby
class ExcelController < ApplicationController
  #table作成
  def export
    @day = Day.find(params[:day_id])
    @user = User.includes(:jobs).where("id > ?", 1)
    @user_name = User.all.pluck(:id,:name).to_h
    @row = 0

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Sheet1") do |sheet|

      sheet.page_margins do |margins|
        margins.left = 0      # 左余白
        margins.right = 0     # 右余白
        margins.top = 0       # 上余白
        margins.bottom = 0    # 下余白
        margins.header = 0    # ヘッダー余白
        margins.footer = 0    # フッター余白
      end

      empty_row = Array.new(30, " ")

      day_week = ["#{@day.start.month}月#{@day.start.day}日（月）",
                  "#{(@day.start+1).month}月#{(@day.start+1).day}日（火）",
                  "#{(@day.start+2).month}月#{(@day.start+2).day}日（水）",
                  "#{(@day.start+3).month}月#{(@day.start+3).day}日（木）",
                  "#{(@day.start+4).month}月#{(@day.start+4).day}日（金）",
                  "#{(@day.start+5).month}月#{(@day.start+5).day}日（土）",
                  "#{(@day.start+6).month}月#{(@day.start+6).day}日（日）",]
      
      event_day = [@day.mon_by?(@day.id),
                   @day.tue_by?(@day.id),
                   @day.wed_by?(@day.id),
                   @day.thu_by?(@day.id),
                   @day.fri_by?(@day.id),
                   @day.sat_by?(@day.id)]
      
      style_method = style_box(workbook)

  #月曜日
    head_print(sheet, workbook, empty_row, day_week, event_day, style_method, 0)
    shift_print(workbook, sheet, :time1, empty_row, style_method, 0)

  #火曜日
    head_print(sheet, workbook, empty_row, day_week, event_day, style_method, 1)
    shift_print(workbook, sheet, :time2, empty_row, style_method, 1)

  #水曜日
    head_print(sheet, workbook, empty_row, day_week, event_day, style_method, 2)
    shift_print(workbook, sheet, :time3, empty_row, style_method, 2)

  #木曜日
    head_print(sheet, workbook, empty_row, day_week, event_day, style_method, 3)
    shift_print(workbook, sheet, :time4, empty_row, style_method, 3)

  #金曜日
    head_print(sheet, workbook, empty_row, day_week, event_day, style_method, 4)
    shift_print(workbook, sheet, :time5, empty_row, style_method, 4)

  #土曜日
    head_print(sheet, workbook, empty_row, day_week, event_day, style_method, 5)
    shift_print(workbook, sheet, :time6, empty_row, style_method, 5)

  #日曜日
    head_print(sheet, workbook, empty_row, day_week, event_day, style_method, 6)
    shift_print(workbook, sheet, :time7, empty_row, style_method, 6)
    
    sheet.add_row(empty_row, style: style_method[:border_style], height: 25)
    @row += 1
    sheet.add_row(empty_row, style: style_method[:footer_style], height: 25)
    @row += 1

    sheet.rows[@row-1].cells[0].value = "#{(@day.start).year} シフト表"
    sheet.merge_cells("A#{@row}:AC#{@row}")

      #列の幅指定（最後）
      sheet.column_widths 13.5, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 2.4, 11.5, 12
    end
    send_data package.to_stream.read, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename: "#{@day.start.month}月#{@day.start.day}日～.xlsx"
  end

  private

    def style_box(workbook)
      {
        top_style: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: { style: :medium,color: '000000', edges: [:top] },
          font_name: "AR丸ゴシック体M"),

        bottom_style: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: { style: :medium, color: '000000', edges: [:bottom] },
          font_name: "AR丸ゴシック体M"),

        border_style: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: { style: :medium, color: '000000', edges: [:bottom, :top] },
          font_name: "AR丸ゴシック体M"),

        footer_style: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: { style: :medium, color: '000000', edges: [:bottom, :top] },
          b: true,
          font_name: "HGP創英角ﾎﾟｯﾌﾟ体"),

        manager_style: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: [{ style: :thin, color: '000000', edges: [:right, :bottom] },
                  { style: :medium, color: "000000", edges: [:left] }],
          fg_color: "00B050",
          b: true,
          font_name: "AR丸ゴシック体M"),
        
        name_style: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: [{ style: :thin, color: '000000', edges: [:right, :bottom] },
                  { style: :medium, color: "000000", edges: [:left] }],
          font_name: "AR丸ゴシック体M"),

        blue_font: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: { style: :medium, color: '000000', edges: [:bottom] },
          fg_color: "0070C0",
          font_name: "AR丸ゴシック体M"),

        red_font: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: { style: :medium, color: '000000', edges: [:bottom] },
          fg_color: "FF0000",
          font_name: "AR丸ゴシック体M"),

        #塗りつぶしメソッド
        blue_n2: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          bg_color: "4BACC6", 
          border: [{ style: :medium, color: "000000", edges: [:right] },
                  { style: :thin, color: "000000", edges: [:bottom] }],
          font_name: "AR丸ゴシック体M"
        ),
        blue_n1: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          bg_color: "4BACC6",
          border: { style: :thin, color: "000000", edges: [:right, :bottom] },
          font_name: "AR丸ゴシック体M"
        ),

        white_n2: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: [{ style: :medium, color: "000000", edges: [:right] },
                  { style: :thin, color: "000000", edges: [:bottom] }],
          font_name: "AR丸ゴシック体M"
        ),
        white_n1: workbook.styles.add_style(
          alignment: { horizontal: :center ,vertical: :center},
          border: { style: :thin, color: "000000", edges: [:right, :bottom] },
          font_name: "AR丸ゴシック体M"
        ),
      }
    end

    def head_print(sheet, workbook, empty_row, day_week, event_day, style_method, week_n)

      if week_n == 0
        sheet.add_row(empty_row, style: style_method[:bottom_style], height: 7)
        @row += 1
      elsif week_n == 4
        sheet.add_row(empty_row, style: style_method[:top_style])#印刷分かれる
        @row += 1
        sheet.add_row(empty_row, style: style_method[:bottom_style], height: 20)
        @row += 1
      elsif week_n == 5 || week_n == 6
        sheet.add_row(empty_row, style: style_method[:border_style], height: 30)
        @row += 1
      else
        sheet.add_row(empty_row, style: style_method[:border_style], height: 8)
        @row += 1
      end

      sheet.add_row(empty_row, style: style_method[:bottom_style], height: 16.5)
        @row += 1

      merge_ranges = ["C#{@row}:D#{@row}", "E#{@row}:F#{@row}", "G#{@row}:H#{@row}", "I#{@row}:J#{@row}", "K#{@row}:L#{@row}",
                      "M#{@row}:N#{@row}", "O#{@row}:P#{@row}", "Q#{@row}:R#{@row}", "S#{@row}:T#{@row}", "U#{@row}:V#{@row}",
                      "W#{@row}:X#{@row}", "Y#{@row}:Z#{@row}", "AA#{@row}:AB#{@row}"]

      merge_ranges.each { |range| sheet.merge_cells(range) }
      head = ["#{day_week[week_n]}", "", 10, "", 11, "", 12, "", 13, "", 14, "", 15, "", 16, "", 17, "", 18, "", 19, "", 20, "", 21, "", 22, ""]
      head.each_with_index do |value, i|
        sheet.rows[@row-1].cells[i].value = value
      end

      if week_n <= 4
        if event_day[week_n]
          sheet.rows[@row-1].cells[0].style = style_method[:red_font]
        end
      elsif week_n == 5
        if event_day[week_n]
          sheet.rows[@row-1].cells[0].style = style_method[:red_font]
        else
          sheet.rows[@row-1].cells[0].style = style_method[:blue_font]
        end
      elsif week_n == 6
        sheet.rows[@row-1].cells[0].style = style_method[:red_font]
      end

      (2..26).step(2).each { |int| sheet.rows[@row-1].cells[int].type = :integer }

    end

    def shift_print(workbook, sheet, time_column, empty_row, style_method, week_n)

      shift_box = []
      shift_box[0] = [1 ,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,""]
      #抜き取る
      userid = 1
      times = []
      @user.each_with_index do |user,u|
        user.jobs.where(day_id: @day.id).each_with_index do |job|
          time_n = job.public_send(time_column)
          unless time_n.blank? || time_n == "×" || time_n == "❌" || time_n == "✖"
            shift_box[userid] = ["",false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,""]
            shift_box[userid][0] = user.id
            shift_box[userid][29] = time_n
            times[userid - 1] = []
            if time_n.match?(/F/i)
              times[userid - 1] = [9,21]
            elsif time_n.match?(/\d/)
              times[userid - 1] = time_n.scan(/\d+/)
              times[userid - 1] = times[userid - 1].map(&:to_i)
              if time_n.match?(/L/i)
                times[userid - 1] << 21
              end
            else
              times[userid - 1] = [22,22]
            end
            userid += 1
          end
        end
      end

      if week_n == 0
        while userid < 11
          shift_box[userid] = ["",false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,""]
          userid += 1
        end
      elsif week_n >= 4
        while userid < 12
          shift_box[userid] = ["",false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,""]
          userid += 1
        end
      else
        while userid < 10
          shift_box[userid] = ["",false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,""]
          userid += 1
        end
      end

      userid.times do
        sheet.add_row(empty_row, height: 16.5)
        @row += 1
      end

      #並び替え
      swap = true
      while swap
        swap = false
        (1...times.length).each do |n|
          if times[n][0] < times[n-1][0]
            times[n], times[n-1] = times[n-1], times[n] # 要素を入れ替え
            shift_box[n+1][0], shift_box[n][0] = shift_box[n][0], shift_box[n+1][0]
            shift_box[n+1][29], shift_box[n][29] = shift_box[n][29], shift_box[n+1][29]
            swap = true
          end
        end
      end
      
      #読み取った数値からtrueを特定の場所へ格納
      times.each_with_index do |k,n|
        k.each_with_index do |i,j|
          if i == 5 || i == 30
            y = (2*k[j-1])-17
            shift_box[n+1][y] = false
            shift_box[n+1][y+1] = true
          elsif 9 <= i && i <= 21
            y = (2*i)-17
            shift_box[n+1][y] = true
          end
        end
      end

      #間をtrueで埋める
      shift_box.each_with_index do |k,j|
        next if j == 0
        triga = 0
        k[0...-1].each_with_index do |i,n|
          next if n == 0
          if triga == 0
            if i == true
              triga = 1
            end
          else
            if i == true
              shift_box[j][n] = false
              break
            else
              shift_box[j][n] = true
            end
          end
        end
      end

      shift_box.each_with_index do |k,i|
        k.each_with_index do |j,x|
          if j == true
            if x % 2 == 0
              sheet.rows[@row - userid + i].cells[x].style = style_method[:blue_n2]
            else
              sheet.rows[@row - userid + i].cells[x].style = style_method[:blue_n1]
            end
          elsif j == false
            if x % 2 == 0
              sheet.rows[@row - userid + i].cells[x].style = style_method[:white_n2]
            else
              sheet.rows[@row - userid + i].cells[x].style = style_method[:white_n1]
            end
          elsif j.is_a?(Integer)
            sheet.rows[@row - userid + i].cells[x].value = @user_name[j].length >= 10 ? @user_name[j][0, 4] : @user_name[j]
            if j == 1
              sheet.rows[@row - userid + i].cells[x].style = style_method[:manager_style]
            else
              sheet.rows[@row - userid + i].cells[x].style = style_method[:name_style]
            end
          elsif x == 29
            sheet.rows[@row - userid + i].cells[x].value = j
          else
            sheet.rows[@row - userid + i].cells[x].style = style_method[:name_style]
          end
        end
      end

    end

end
```
</details>


## 今後の展望

当アプリケーションは、店舗のシフト希望名簿をWeb上に移行するという明確な目的のもと、Ruby on Railsを用いて構築しました。  
開発当初は経験も浅く、コードやデータベース構造には無駄が多く、変数名にも一貫性がないなど、技術的な改善点が多く残されています。

今後はこれらの課題を踏まえて、以下のような改良を加え、**「シフト提出〜作成〜管理」までを一貫して担える、より実用的なアプリケーション**を目指します。

### 改善予定の技術的ポイント

- **コードのリファクタリング**  
  - 可読性を意識したクリーンな記述
  - 命名規則の統一（変数・メソッド・モデル名など）
- **データベース設計の見直し**  
  - 正規化の見直しと不要テーブルの削減

### 機能追加・拡張の予定

- **Userモデルの状態管理機能**  
  - 在籍／研修中／退職済などの状態を管理するフラグを追加 
- **祝日判定ロジックの改善（`holiday_japan` などのgemを使用）**  
  - 手動で曜日情報を入力するテーブル構造を廃止
- **シフト調整・管理機能の実装**  
  - 独自のアルゴリズムの開発 or AIを活用し、時間帯による人員の自動調整
- **シフト確定後のやりとりに対応**  
  - 確定後の「交換希望」や「急な休み申請」などへの対応をアプリ上で実現

---
