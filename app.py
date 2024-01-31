from flask import Flask, render_template, request
import pandas as pd

app = Flask(__name__)

# URL to access the Google Sheet as CSV (replace 'Sheet1' with your sheet name)
csv_url = 'https://docs.google.com/spreadsheets/d/121BaoNog5TgRNhZ9FFRgjaiczcaepwMUDuMdkfaZFd0/export?format=csv'

# Read the Google Sheet into a pandas dataframe
df = pd.read_csv(csv_url)

@app.route('/', methods=['GET', 'POST'])
def index():
    # Get the search query from the form submission
    search_query = request.form.get('search', '')

    # Filter the dataframe based on the search query
    filtered_df = filter_data(df, search_query)

    return render_template('index.html', table=filtered_df.to_html(), search_query=search_query)

def filter_data(data, search_query):
    # Implement your filtering logic here based on the search query
    # For simplicity, this example filters based on the 'name' column
    return data[data['name'].str.lower().str.contains(search_query.lower())]

if __name__ == '__main__':
    app.run(debug=True)