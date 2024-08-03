export default function WaitingSpin({ visible }) {
  const maskStyle = {
    'background-color': 'rgba(0.0, 0.0, 0.0, 0.3);'
  };
  console.log("spinning");
  return (
    <div className="modal fade" tabindex="-1" role="dialog">
      <div className="modal-dialog modal-dialog-centered justify-content-center">
        <div className="modal-content">
          <span className="fa fa-spinner fa-spin fa-3x"></span>
        </div>
      </div>
    </div>
  );
}
